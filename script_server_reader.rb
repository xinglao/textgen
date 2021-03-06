#!/usr/bin/env ruby
#
require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'
require 'dotenv'
require 'raven'

Dotenv.load

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

Raven.capture do
  require './lib/conversation'

  $stdout.sync = true

  redis = Redis.new

  output = File.open("/var/tmp/scriptserver.out", "r")
  loop do
    puts 'reading output'
    data = output.gets
    msg = {:data => data, :script_server => IPAddress.my_first_public_ipv4}.to_json
    puts 'publishing output:' + msg 
    redis.publish('script_server_out', msg)
  end
end
