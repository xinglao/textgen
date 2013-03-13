#!/usr/bin/env ruby
require File.expand_path('..') + '/lib/script_conversation'

conversation do
  ask :logging_in, 'Welcome to the employee time clock. Are you clocking in for the day? (y/n)', :as => /(y|n)/
  if logging_in == 'y'
    say "Logging in now. Thanks!"
    record :login_time, Time.now
  else
    say "You are logged out for the day."
    record :logout_time, Time.now
    ask :diary, 'Can you give me a short summary of what you did today?'
    say "Thank you! Have a great rest of your day."
  end
end
