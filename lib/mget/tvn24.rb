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

class TVN24 < MovieSite
    def get()
      id = @url.scan(/http:\/\/www\.tvn24\.pl\/(.+?),.+?,.+?,.+?,.+?,wideo\.html$/).flatten
      id = id.to_s

      open("http://www.tvn24.pl/" + id + ",md.xml") do |f|
        f.each_line do |line|
          if line =~ /<vid>(.+?)<\/vid>/
            return "http://www.tvn24.pl/_mmv/" + $1 + ",5.flv"
          end
        end
      end
    end
end
