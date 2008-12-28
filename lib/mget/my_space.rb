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

class MySpace < MovieSite
  def get()
    id = 0
    if @url =~ /VideoID=(\d{0,10})/i
      id = $1.to_s
    else
      setError("Invalid myspace link, are you sure you copied it correctly?\n")
      return nil
    end

    open("http://mediaservices.myspace.com/services/rss.ashx?type=video&videoID=" + id) do |f|
      f.each_line do |line|
        if line =~ /content url="(http:\/\/.+?)" type/
          return $1
        end
      end
    end
  end
end
