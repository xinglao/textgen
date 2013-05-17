#!/usr/bin/env ruby
require File.expand_path('../../lib/script_conversation', __FILE__)

conversation do
  say "Welcome to Joe's apartment registration."
  # Hey, a validator for dates would be extremely handy.
  ask :start_date, "Please enter start date (dd-mm-yyyy).", :as => /[0-9]{2}-[0-9]{2}-[0-9]{2}/, :tries => 3
  ask :ndays, "How many nights would you like to stay?", :as => :number
  ask :nrooms, "How many rooms do you need?", :as => :number
  ask :name, "Registering #{nrooms} room(s) for #{ndays} day(s). Please enter you name."
  ask :address, "Please enter your current address."
  ask :phonenumber, "Please enter your phone number."
end
