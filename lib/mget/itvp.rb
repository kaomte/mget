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

class ITVP < MovieSite

  def initialize(url,config)
    super(url,config)
    @mms         = true
    @convertable = false
  end

  def get()
    @suffix = '.wmv'
    @out = ''
    mode, id = @url.scan(/http:\/\/www\.itvp\.pl\/player\.html\?mode=(.+?)&channel=.+?&video_id=(.+?)$/).flatten
    @url1 = "http://www.itvp.pl/pub/stat/common/materialinfo2?mode=#{ mode }&material_id=&format_id=&video_id=#{ id }"

    open(@url1) do |f|
      f.each_line do |line|
        if line =~ /\<material\>(.+?)\<\/material\>/
          @material = $1
        end
        
        if line =~ /format id="(.+?)"/
          @id = $1
        end
      end
    end
    
    open("http://www.itvp.pl/pub/sdt/locator?format_id=#{@id}&mode=#{ mode }&material_id=#{ @material }") do |f|
      f.each_line do |line|
        if line =~ /<request_id>(.+?)<\/request_id>/
          @request = $1
        end
      end
    end

    @out = "http://www.itvp.pl/pub/sdt/itvp.asx?request_id=#{ @request }"

    @out.gsub!('%2f', '/')
    @out.gsub!('%3d', '=')
    @out.gsub!('%3d', '')
    @out.gsub!('%2b', '+')

    return @out
  end
end