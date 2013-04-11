#!/usr/bin/env ruby
require File.expand_path('..') + '/lib/script_conversation'

conversation do
  say 'Welcome to Poutine on the Ritz, Quebecs Health Food Take Out' 

  # { question: '...', :responses => ['yes','no'], :as => :select }
  
  ask :specials, "You would like to see our specials today? (y/n)", :as => :yes_or_no
  # web? => [x] yes, [x] no?
  # sms? => (yes or no)
  # email? => (respond with 'yes' for yes and 'no' for no)
  # ivr? (press 1 for yes and press 2 for no)
  if specials == 'y' then
    say "We have a very special french fry, cheese and gravy dish."
  end

  finished = false
  items = Array.new

  until finished
    ask :item, "What would you like to order?"
    items << item

    ask :anything_else, "Anything else? (y/n)", :as => /y|n/
    finished = true if anything_else == "n"
  end 

  record :items, items

  # Don't need to report these
  hide [:item, :specials, :anything_else]
  say "Thank you. We'll get that right up. Please head on down in 20 minutes"

end
