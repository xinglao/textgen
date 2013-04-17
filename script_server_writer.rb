#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'json'
require 'active_support/all'

require './lib/conversation'

redis = Redis.new(:timeout => 0)

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
