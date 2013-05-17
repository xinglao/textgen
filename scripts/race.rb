#!/usr/bin/env ruby
require File.expand_path('../../lib/script_conversation', __FILE__)

conversation do
  say "Welcome to Acme road race registration."
  ask :name, "Please enter your name."
  ask :age, "Please enter your age.", :as => :number

  ask :withclub, "Would you like to register a club name? (y/n)", :as => /y|n/i
  if withclub.downcase == "y"
	  ask :club, "What is the name of the club?"
  end
  hide :withclub

  ask :tshirt, "Would you like a free t-shirt? (y/n)", :as => /y|n/i
end
