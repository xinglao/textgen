require 'pry'
require_relative 'app'

script_name = ARGV[0]
script_dir = File.expand_path('./scripts')
script_path = File.join(script_dir, script_name + '.rb')

puts "creating thread"
puts script_path

script = Thread.new do
  require script_path
end
script.join
