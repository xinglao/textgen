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

while true do
  msg = redis.blpop("script_servers_in").last
  Conversation.handle_message(msg)
end
