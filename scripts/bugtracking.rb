#!/usr/bin/env ruby
require File.expand_path('../../lib/script_conversation', __FILE__)

conversation do
  say "Textgen bug tracking syste."
  ask :version, "Please enter software version."
  ask :browser, "What browser were you using?"
  ask :description, "Please enter the description of the bug."

  ask :canreproduce, "Can you reproduce the problem? (y/n)", :as => /y|n/i
  if canreproduce.downcase == "y"
	  ask :steps, "Please enter the scenario to reproduce the bug."
  end
  hide :canreproduce
end
