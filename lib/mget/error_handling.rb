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

require 'logger'

module ErrorHandling

  def error?
    return !@error.nil?
  end
  
private
  def setError(string)
    @error = "[!] " + string
    puts @error
    @log.error(string)
  end
  
  def setWarning(string)
    @warn = "[*] " + string
    puts @warn
    @log.warn(string)
  end
  
  def setInfo(string)
    @info = "[?] " + string
    puts @info
    @log.info(string)
  end

  # trace script internals without disturbing the user
  def setTrace(string)
    if trace?
      @log.info(string)
	end
  end
  
  def logDir()
    path = './'
    if ENV.has_key?('APPDATA')
	  path = 'C:\\Program Files\\mget\\'
	  Dir.mkdir(path) unless File.exists?(path) && File.directory?(path)
	  path += 'logs\\'
    else
      path = ENV['HOME'] + '/.mget/'
    end
    Dir.mkdir(path) unless File.exists?(path) && File.directory?(path)
    return path
  end
end