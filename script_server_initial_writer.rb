#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'
require 'dotenv'
require 'raven'
require 'rest-client'

Dotenv.load

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
end

Raven.capture do
  require './lib/conversation'

  $stdout.sync = true

  redis = Redis.new

  while true do
    msg = redis.blpop("script_servers_in").last
    Conversation.handle_message(msg)
  end
end
