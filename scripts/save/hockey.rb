#!/usr/bin/env ruby
require File.expand_path('..') + '/lib/script_conversation'

conversation do
  ask :permission, 'Welcome to the NEJH tryout signup page. Your cell number will be automatically recorded. OK? (y/n)', :as => /y|n/ 
  if permission == 'y' then
    ask :birth_year, "What is the birth year of your player?"
    ask :name, "Please text the name of your player"
    ask :year, "How many years has she played hockey?", :as => :number
  else
    say "Ok, sorry for that."
  end

  record :fill_in_time, Time.now
  record :called_number, "123123213232"
  
end