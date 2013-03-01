#!/usr/bin/env ruby
require File.expand_path('..') + '/lib/script_conversation'

conversation do
  say 'Welcome to Poutine on the Ritz, Quebecs Health Food Take Out' 
  
  ask :specials, "You would like to see our specials today? (y/n)", :as => /y|n/
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