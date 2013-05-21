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

loop do
  puts 'reading output'
  output = File.open("/var/tmp/scriptserver.out", &:gets)
  puts 'publishing output:' + output
  redis.publish('script_server_out', output)
end
