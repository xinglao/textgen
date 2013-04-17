#!/usr/bin/env ruby
#
require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'

require './lib/conversation'

loop do
  puts 'reading output'
  output = File.open("/var/tmp/scriptserver.out", &:gets)
  puts 'publishing output:' + output
  Redis.new.publish('script_server_out', output)
end
