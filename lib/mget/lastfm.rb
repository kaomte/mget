# This file is part of the 'Movie Get' project.
#
# Copyright (C) 2006 Adam Wolk "mulander" <netprobe@gmail.com>
#                                "defc0n" <defc0n@da-mail.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'mget/movie_site'
require 'net/https'
require 'base64'
require 'cgi'

class Net::HTTP
  alias :old_use_ssl= :use_ssl=
  
  def use_ssl= flag
    self.old_use_ssl = flag
    @ssl_context.tmp_dh_callback = proc {}
  end
end

class LastFM < MovieSite
  def get()
    if @url =~ /\+videos/
      getVideo
    else
      getAudio()
    end
  end
  
  def getVideo()
    id = @url.scan(/videos\/(\d+?)$/)
    open("http://ext.last.fm/1.0/video/getplaylist.php?vid=#{id}") do |f|
      f.each_line do |line|
        if line =~ /<location>(.+?)<\/location>/
          return $1
        end
      end
    end
  end
  
  def getAudio()
    @suffix = '.mp3'
    id = 0
    out = nil

    open(@url) do |f|
      f.each do |line|
        id = $1 if line =~ /resourceID=(.+?)\&/
      end
    end

    if id == 0
      setError("Track does not exist: #{ @url }")
      exit
    end
    
    def login
      http = Net::HTTP.new('www.last.fm', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      path = '/login/'
      resp = http.get(path, nil)
      cookie = resp['set-cookie']
      
      data = "username=#{@username}&password=#{@password}"
      headers = {
        'Cookie' => cookie,
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      resp = http.post(path, data, headers)
      
      if resp['set-cookie'] == nil
        @username = nil
        @password = nil
        setWarning("Invalid username or password")
        return false
      else

        @loggedIn = true
        return resp['set-cookie'].scan(/Session=(.+?);/)
      end
    end

    setInfo("To use the LastFM module, you need at least 14 tracks on Your playlist!")

    until loggedIn?
      askAccountInfo() unless usernameSet? && passwordSet?
      session = login
    end

    http = Net::HTTP.new('www.last.fm', 80)
    path = "/user/#{@username}/playlist/"
    data = "action=addtrack&ajax=1&trackid=#{id}"
    headers = {
      'Cookie' => "Session=#{session}",
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
    }
    http.post(path, data, headers)

    open("http://ext.last.fm/radio/adjust.php?widget_id=playlist&client_id=undefined&session=#{session}&url=lastfm://user/#{@username}/playlist&user=#{@username}&onData=%5Btype%20Function%5D")

    checked = 0
    stuff = Array.new
    while(checked != -1)
      checked += 1
      
      open("http://www.last.fm/flash_getplaylist.php?sk=#{session}") do |f|
        f.each do |line|
          stuff = CGI::unescape(Base64.decode64(line))
        end
      end

      elements = stuff.split('<track>')
      stuff = Array.new
      location = nil
      idSong = nil
      elements.each do |line|
        location = $1 if line =~ /<location>(.+?)<\/location>/
        idSong = $1 if line =~ /<id>(.+?)<\/id>/
        stuff << [idSong, location] if location != nil && idSong != nil
      end

      stuff.each do |element|
        if element[0] == id
          out = element[1]
          checked = -1
        end
      end

      if checked == 10
        setError("Track not found. Check the number of tracks on Your playlist!")
        exit
      end
    end

    data = 'action=save&title=MGET'
    open("http://www.lastfm.pl/user/#{@username}/playlist/?action=edit&removed[]=#{id}", {'Cookie' => "Session=#{session}"}) do |f|
      f.each_line do |line|
        data += "&track%5B%5D=#{$1}" if line =~ /name="track\[\]" value="(.+?)"/
        data += "&trackorder#{$1}=#{$2}" if line =~ /name="trackorder(.+?)" value="(.+?)"/
      end
    end
    data += '&showhide=1'

    http = Net::HTTP.new('www.last.fm', 80)
    path = "/user/#{@username}/playlist/"
    headers = {
      'Cookie' => "Session=#{session}",
      'Referer' => 'http://www.lastfm.pl/',
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'
    }
    http.post(path, data, headers)

    return out
  end
end
