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
require 'yaml'

module Config
  @@config  = {
                  :trace => false,
                  :accounts => {
                    :setup => {
                      :store => :usernames # :usernames, :all or :both, :nothing
                    },
                    :Youtube => {
                      :username => nil,
                      :password => nil
                    },
                    :LastFM  => {
                      :username => nil,
                      :password => nil
                    }
                  },
                  :proxy => {
                    :address => nil,
                    :port    => nil
                  }
  }
  @@default_config = @@config
  # Load the current configuration from disk
  def loadConfig()
    target = getConfigPath() + @@type + 'mget.yaml'
    @@config = YAML.load_file(target) if File.exists?(target)
    return true
  end
  # Save the current configuration to disk
  def saveConfig()
    path = getConfigPath()
    Dir.mkdir(path) unless File.exists?(path) && File.directory?(path)
    target =  path + @@type + 'mget.yaml'
    ## apply storage rules
    ## before saving the configuration
    ## we have 3 possible options for storing account settings
    ## :all or :both => store both username and password
    ## :usernames => store only the usernames
    ## :nothing => do not store any account information
    storage_mode = @@config[:accounts][:setup][:store]

    @@config[:accounts].each { |key,site|
      next if key == :setup
      if storage_mode == :usernames
          site[:password] = ''
      elsif [:all,:both].include? storage_mode
          site[:username] = ''
          site[:password] = ''
      end
    }
    File.open(target,"w") { |file| YAML.dump(@@config,file) }
  end
  # Return the path to the config file
  def getConfigPath()
    path = './'
    if ENV.has_key?('APPDATA')
      path = ENV['APPDATA'] + '\\mget\\'
      @@type = '\\'
    else
      path = ENV['HOME'] + '/.mget/'
      @@type = '/'
    end
    return path
  end
end