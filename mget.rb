#!/usr/bin/ruby -w
# v1.50
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

$LOAD_PATH.push('lib')

require 'getoptlong'
require 'mget/mget'
require 'mget/config'

class Mget
  include Config
end

opts = GetoptLong.new(
  ["--help","-h",       GetoptLong::NO_ARGUMENT],
  ["--name","-n",       GetoptLong::REQUIRED_ARGUMENT],
  ["--input","-i",      GetoptLong::REQUIRED_ARGUMENT],
  ["--download","-d",   GetoptLong::NO_ARGUMENT],
  ["--nodownload","-D", GetoptLong::NO_ARGUMENT],
  ["--convert","-c",    GetoptLong::NO_ARGUMENT],
  ["--remove","-r",     GetoptLong::NO_ARGUMENT],
  ["--noremove","-R",   GetoptLong::NO_ARGUMENT],
  ["--noconvert","-C",  GetoptLong::NO_ARGUMENT],
  ["--show","-s",       GetoptLong::NO_ARGUMENT],
  ["--quiet","-q",      GetoptLong::NO_ARGUMENT],
  ["--version","-v",      GetoptLong::NO_ARGUMENT]
)

opts.ordering = GetoptLong::REQUIRE_ORDER

mget = Mget.new()
begin
  opts.each do |opt, arg|
    case opt
      when '--help'
        Mget.help()
      when '--name'
        mget.name   = arg
      when '--input'
        mget.input  = arg
      when '--download'
        mget.download = true
      when '--nodownload'
        mget.download = false
        mget.show     = true
      when '--convert'
        mget.convert  = true
      when '--noconvert'
        mget.convert  = false
      when '--remove'
        mget.remove   = true
      when '--noremove'
        mget.remove   = false
      when '--show'
        mget.show     = true
      when '--quiet'
        mget.quiet    = true
      when '--version'
        Mget.version()
    end
  end
rescue GetoptLong::InvalidOption
  Mget.help()
end
mget.target = ARGV[0] unless mget.fromFile?

mget.loadConfig()
mget.run()
mget.saveConfig()