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

class Patrz < MovieSite
  def get()
    def cookie(url)
      if url =~ /http:\/\/(.+?)(\/.+?)$/
        http = Net::HTTP.new($1, 80)
        data = http.get($2, nil)

        if data['location'] != nil && data['location'] != @url
          cookie(data['location'])
        else
          return data['set-cookie'].to_s
        end
      end
    end

    if @url =~ /http:\/\/.+?\.patrz\.pl\/$/
      http = Net::HTTP.new(URI.parse(@url).host, 80)
      data = http.get('/', nil)
      @url = data['location']
    end

    www = URI.parse(@url)
    cookies = cookie(@url)
    http = Net::HTTP.new(www.host, 80)
    http.get(www.path, { 'Cookie' => cookies }) do |line|
      if line =~ /fid=(.+?);/
        file = $1

        case @url
          when /filmy/
            return 'http://www27.patrz.pl/uplx/5flv/' + file + '.flv'
          when /mp3/
            @suffix = '.mp3'
            return 'http://www27.patrz.pl/uplx/5fla/' + file + '.flva'
        end
      end
    end 
  end
end