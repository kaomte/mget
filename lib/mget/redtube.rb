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

class RedTube < MovieSite
  def get()
    id = @url.scan(/([0-9]+)$/).flatten.to_s
    vid = (id.to_f / 1000).floor.to_s
    id = "0" * (7 - id.length) + id
    vid = "0" * (7 - vid.length) + vid
    map = ["R", "1", "5", "3", "4", "2", "O", "7", "K", "9", "H", "B", "C", "D", "X", "F", "G", "A", "I", "J", "8",
            "L", "M", "Z", "6", "P", "Q", "0","S", "T", "U", "V", "W", "E", "Y", "N"]

    myInt = 0
    0.upto(6) { |i| myInt += (id[i,1].to_i * (i + 1)) }

    myChar = myInt.to_s.split('')
    myInt = 0
    0.upto(myChar.length + 1) { |i| myInt += myChar[i].to_i }

    if myInt >= 10
      newChar = "#{myInt}"
    else
      newChar = "0#{myInt}"
    end

    newChar = newChar.split('')
    mapping = map[id[3] - 48 + myInt + 3] + newChar[1] + map[id[0] - 48 + myInt + 2] + map[id[2] - 48 + myInt + 1] +
              map[id[5] - 48 + myInt + 6] + map[id[1] - 48 + myInt + 5] + newChar[0] + map[id[4] - 48 + myInt + 7] +
              map[id[6] - 48 + myInt + 4]
      
    return "http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/#{vid}/#{mapping}.flv"
  end
end