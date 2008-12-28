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

class Youtube < MovieSite
  @@cookieSet = false
  @@cookieMem = ''
  def initialize(url,config)
    super(url,config)
    @cookie = @@cookieMem if @@cookieSet
    if @url =~ /(\/watch.+)/
      @base  = 'youtube.com'
      @watch = $1
    else
      setError("Invalid Youtube link")
    end
  end
  
  def get()
    return if error?
    id = ''
    open(@url,{'Cookie' => @cookie, 'User-Agent' => @useragent}) do |f|
      if adult?(f.base_uri.to_s)
        until loggedIn?
          askAccountInfo() unless usernameSet? && passwordSet?
          login
        end
        confirm
        return get()
      end
      f.each_line do |line|
          if line =~ /video_id":\s+"(.+?)".+?t":\s+"(.+?)"/
            return "http://youtube.com/get_video?video_id=#{$1}&t=#{$2}"
          end
        end
      end
  end
  
  private
  
  def login() # seems to work
    res = Net::HTTP.post_form(URI.parse('http://' + @base + '/login?next_url=' + @watch),
                              {'current_form' => 'loginForm','username' => @username,
                               'password' => @password, 'next_url' => @watch,
                               'action_login' => 'Log In' })
  # Youtube sends 303 on a valid login attempt and 200 if failed
    case res.code
      when '303'
        @cookie   = res['set-cookie'].split(' ').find_all { |p| p =~ /use|INFO/ }
        @cookie   = @cookie.join(' ')
        @loggedIn = true
        return true
      when '200'
        @username = ''
        @password = ''
        setWarning("Invalid username or password")
        return false
      end
  end
  
  def confirm
    data = 'next_url=#@watch&action_confirm=Confirm'
    headers = {
      'Cookie' => @cookie,
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    http    =   Net::HTTP.new(@base,80)
    res     =   http.post(@confirm, data, headers)
    @cookie +=  ' ' + res['set-cookie'].split(' ').find { |p| p =~ /is_adult/ }
    @@cookieMem = @cookie
    @@cookieSet = true
  end
  
  def adult?(url)
    if url =~ /(\/verify_age.+)/
      @confirm = $1
      return true
    else
      return false
    end
  end
end
