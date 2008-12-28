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

require 'mget/error_handling'
require 'mget/config'
require 'open-uri'
require 'net/http'
require 'uri'

class MovieSite
  include ErrorHandling
  include Config
  attr_reader :suffix
  def initialize(url,config)
    @log = Logger.new(logDir() + self.class.to_s + '.log')
    @error    = nil
    @url      = url
    @cookie   = ''
    @loggedIn = false
    @suffix   = '.flv'
    @mms      = false
    @useragent= 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111'
    unless config.nil?
      # @@config => :accounts => :movie_site_name => :username or :password
      @username = @@config[:accounts][self.class.to_s.to_sym][:username]
      @password = @@config[:accounts][self.class.to_s.to_sym][:password]
    else
      @username = nil
      @password = nil
    end
  end
  
  def mms?
    @mms
  end
  
  private
  def passwordSet?
    return (@password.nil? || @password.empty?) ? false : true
  end
  def usernameSet?
    return (@username.nil? || @username.empty?) ? false : true
  end
  
  def loggedIn?
    return @loggedIn
  end
 
  def askPassword
    print "#{ self.class } password: "
    @password = $stdin.gets.chomp
    @@config[:accounts][self.class.to_s.to_sym][:password] = @password
  end
  
  def askUsername
    print "#{ self.class } username: "
    @username = $stdin.gets.chomp
    @@config[:accounts][self.class.to_s.to_sym][:username] = @username
  end  

  def askAccountInfo
    puts "#{ self.class } decided that in order to view this movie you must identify"
    until usernameSet?
      askUsername()
    end
    
    until passwordSet?
      askPassword()
    end
  end

end
