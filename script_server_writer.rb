#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'

require './lib/conversation'

Dotenv.load

$stdout.sync = true

redis = Redis.new(host: ENV['TEXTGEN_REDIS_SERVER'])

redis.subscribe('script_server_in') do |redis_channel|
  redis_channel.message do |channel, msg|
    puts msg
    params = JSON.parse(msg)

    convo = Conversation.new(
      params['user_id'],
      params['script'],
      params['script_version'],
      params['script_url']
    )
    message = params['message']

    puts 'writing input:' + message.to_s
    convo.write(message)
  end
end
