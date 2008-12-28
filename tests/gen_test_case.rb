#!/usr/bin/ruby -w
# usage:
# ruby gen_test_case.rb MetaCafe meta_cafe
#			^		^
#			class name	file name
# add links in format target_link*download_link
# EXAMPLE target_link*download_link
# http://pl.youtube.com/watch?v=zJEK6exnaZE*http://74.125.13.23/get_video?video_id=zJEK6exnaZE
#                                          ^ notice the separator
# use at least 5 sets of target_link*download_link for
# each generated test case
# after generating the test file
# modify the @suffix variable to reflect the specific case
# modify the mms test case to reflect the specific case
# assert(!movie.mms?) - for sites without mms streaming
# assert(movie.mms?)  - for sites with mms streaming
# in case of a site that requires some configuration
# locate and modify the following line
# @movies.push( [ #{CLASS_NAME}.new(link,nil), sum ] )
# passing the appropriate configuration variable insted of nil
# make sure to add the new test case to run_tests.rb file.
require 'get_md5sum'


CLASS_NAME = ARGV[0]
FILE_NAME  = ARGV[1]

if ARGV.empty? or ARGV.length < 2
	puts "Usage: ruby gen_test_case.rb ClassName file_name"
	exit
end

file = File.open("tc_" + FILE_NAME + '.rb','w')

links = []

puts "Enter links (format target_link*download_link) to include in the test (download_link obtained with mget -sDC target_link). Hit ^D when done."
while((line = STDIN.gets))
	links.push(  line.strip.split('*')  )
end

if links.empty?
	puts "[!!] You have to enter at least one target_link*download_link pair."
	File.delete("tc_" + FILE_NAME + '.rb')
	exit
end
file << """#!/usr/bin/ruby -w
$LOAD_PATH.push('../lib')

require 'test/unit'
require 'mget/#{ FILE_NAME }'
require 'get_md5sum'

class TC_#{ CLASS_NAME } < Test::Unit::TestCase
	def setup()
		@suffix = '.flv'
		@links = [
"""

links.each do |link,download_link|
file << """			[
					'#{ link }',
					'#{ get_md5sum(download_link) }'
				],
"""
end
file << """	]
		@movies = []
		@links.each do |link,sum|
			@movies.push( [ #{CLASS_NAME}.new(link,nil), sum ] )
		end
	end
	def test_get()
		@movies.each do |movie,sum|
			assert_instance_of( #{CLASS_NAME}, movie )
			assert_equal(sum, get_md5sum(movie.get()) )
		end
	end
	def test_suffix()
		@movies.each do |movie,sum|
			assert_equal(@suffix,movie.suffix())
		end
	end
	def test_mms()
		@movies.each do |movie,sum|
			assert(!movie.mms?)
		end
	end
	def test_errors()
		@movies.each do |movie,sum|
			assert(!movie.error?)
		end
	end
end"""

file.close()
puts "[??] See the comments inside this file for post generation tasks."