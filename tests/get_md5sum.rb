#!/usr/bin/ruby -w
CHUNK_SIZE = 1024 * 10
def get_md5sum(link)
 return `wget "#{link}" -q -O - | head -c #{ CHUNK_SIZE } | md5sum | awk '{print $1}'`.strip
end