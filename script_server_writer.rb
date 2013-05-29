#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'
require 'dotenv'

Dotenv.load

require './lib/conversation'

$stdout.sync = true

redis = Redis.new(host: ENV['TEXTGEN_REDIS_SERVER'])

redis.subscribe("script_server_in_#{ENV['THIS_SCRIPT_SERVER_IP']}") do |redis_channel|
  redis_channel.message do |channel, msg|
    Conversation.handle_message(msg)
  end
end
