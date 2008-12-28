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

class Allocine < MovieSite

  def initialize(url,config)
    super(url,config)
  end

  def get()
    id, id2 = @url.scan(/cmedia=(.+?)&cfilm=(.+?)\.html/).flatten

    open('http://www.allocine.fr/video/xml/videos.asp?media=' + id.to_s + '&ref=' + id2) do |f|
      f.each_line do |line|
        if line =~ /md_path="(.+?)"/
          return 'http://a69.g.akamai.net/n/69/32563/v1/mediaplayer.allocine.fr' + $1 + '.flv'
        end
      end
    end
  end
end