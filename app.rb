require 'pry'
require 'sinatra'
require './lib/conversation'

get '/talk' do
  convo = Conversation.find_or_create(params[:script], params[:user_id])
  convo.write(params[:message]) unless params[:message].nil?
  convo.read
end
