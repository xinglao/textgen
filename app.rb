require 'pry'
require 'sinatra'
require './lib/conversation'

get '/talk' do
  convo = Conversation.find_or_create(
    params[:user_id],
    params[:script],
    params[:script_version],
    params[:script_url]
  )
  message = params[:message]
  convo.write(message) unless message.nil? or message.empty? 
  convo.read
end
