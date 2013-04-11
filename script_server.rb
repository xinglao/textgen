#!/usr/bin/env ruby

require 'rubygems'
require 'redis'
require 'json'

redis = Redis.new(:timeout => 0)

redis.subscribe('script_server_in') do |redis_channel|
  redis_channel.message do |channel, msg|
    params = JSON.parse(msg)

    convo = Conversation.new(
      params[:user_id],
      params[:script],
      params[:script_version],
      params[:script_url]
    )
    message = params[:message]

    convo.write(message)
    Redis.new.publish('script_server_out', convo.read)
  end
end
