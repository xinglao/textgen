#!/usr/bin/env ruby
require File.expand_path('..') + '/lib/script_conversation'

conversation do
  ask :student_name, 'Hello, this is the Barnstable/West Barnstable Elementary School 
      attendance line. Please give us the name of the student.' 
  ask :excused, 'Is this an excused absence?', :as => /(y|n)/
  ask :why, 'Please tell us why your student was not present.'

  # Here's where I want a mode variable to ask for an email address if
  # we aren't doing IVR
  ask :email, 'Please give us your email address so we can send you a confirmation', :as => :email
  say "Thank you!!"
end
