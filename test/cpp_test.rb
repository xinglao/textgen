require './lib/conversation'
require 'json'
File.open("/var/tmp/scriptserver.in", "w+") do |f|
  message =  '{ "command": "/home/subout/code/textgen/scripts/scrump_1.rb" , "dataLine": "h", "uuid": "self.user_id" }'
  f.puts message
  f.flush 
end

File.open("/var/tmp/scriptserver.out", "r") do |output_file|
  output = output_file.gets
  puts output
end

