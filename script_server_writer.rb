#!/usr/bin/env ruby

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

  redis.subscribe("script_server_in_#{IPAddress.my_first_public_ipv4}") do |redis_channel|
    redis_channel.message do |channel, msg|
      Conversation.handle_message(msg)
    end
  end
end
