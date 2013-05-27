#!/usr/bin/env ruby
#
require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'
require 'dotenv'

Dotenv.load

require './lib/conversation'

$stdout.sync = true

redis = Redis.new(host: ENV['TEXTGEN_REDIS_SERVER'])

output = File.open("/var/tmp/scriptserver.out", "r")
loop do
  puts 'reading output'
  result = output.gets
  puts 'publishing output:' + result
  redis.publish('script_server_out', result)
end
