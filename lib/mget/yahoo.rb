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

class Yahoo < MovieSite

  def initialize(url,config)
    super(url,config)
    @mms         = true
    @convertable = false
  end
  
  def get()
    @suffix = '.wmv'
    id = @url.scan(/http:\/\/movies\.yahoo\.com\/movie\/.+?\/video\/(.+?)$/).flatten
    @url = "http://cosmos.bcst.yahoo.com/ver/237/process/getSequence.php?&node_id=#{ id }"

    open(@url) do |f|
      f.each_line do |line|
        if line =~ /makeplaylist\.dll\?sid=(.+?)&/
          sid = $1

          open('http://playlist.yahoo.com/makeplaylist.dll?sid=' + sid.to_s + '&pt=xml') do |f_|
            f_.each_line do |line_|
              if line_ =~ /URL="(.+?)"/
                out = $1
              end

              out = out.to_s
              out.gsub!('&amp;', '&')

              return out
            end
          end
        end
      end
    end
  end
end

