#!/usr/bin/env ruby
#require_relative File.expand_path('..') + '/lib/script_conversation'
require File.expand_path('../../lib/script_conversation', __FILE__)

conversation do
  say 'hello' 
  
  loop do
    ask :number_of_apples, "how many apples do you want?", :as => :number, :optional => true
    ask :type_of_apple, "What type of apple do you want?"

    if number_of_apples < 20 and type_of_apple == "green"
      break 
    else
      say "umm we don't have that many green apples sorry"
    end
  end

  if number_of_apples > 10
    say "man that's a lot of apples"
  else
    say "ok. that is that all"
  end

  ask :age, "What is your age?", :as => :number
  say "You are not old enough to buy this..."
  
  ask :email_address, "What is your email address?", :as => :email

  ask :postal_code, "What's your postal code?", :as => /[A-Z][0-9][A-Z]\ ?[0-9][A-Z][0-9]/i#, :repeat_on_error => true, :error_message => 'nooooo'


  result_set.delete(:apples)

  result_set[:apples] = get_apples_from_3rd_party_api
  record(:apples, get_apples_from_3rd_party_api)
  
  say 'goodbye'
end

