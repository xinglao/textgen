require 'pry'
require 'sinatra'
require './lib/conversation'

get '/talk' do
  convo = Conversation.find_or_create(params[:script], params[:user_id])
  message = params[:message]
  convo.write(message) unless message.nil? or message.empty? 
  convo.read
end
