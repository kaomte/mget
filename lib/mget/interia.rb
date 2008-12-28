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

class Interia < MovieSite
  def get()
    case @url 
      when /teledyski/
        getTeledyski()
      when /video/
        getVideo()
      else
        setError("Unsupported site: #{@url}")
    end
  end
  
  def getTeledyski()
    open(@url) do |f|
      f.each_line do |line|
        if line =~ /name="url" value="(http:\/\/clips\.interia\.pl\/playlist2\.html\?.+?)" \/\>/
          tmp = $1
          tmp.gsub!(/\&amp\;/, "&")
            open(tmp) do |f_1|
              f_1.each_line do |line_1|
                if line_1 =~ /\<ref href="(.+?)"\/\>/
                  return $1
                end
              end
            end
        end
      end
    end
  end
  
  def getVideo()
      id = @url.scan(/http:\/\/video\.interia\.pl\/obejrzyj\,film\,(\d+)\,?.*$/).flatten
      return "http://flv.interia.pl/l/#{ id }.flv"
  end
end
