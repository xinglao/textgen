#!/usr/bin/env ruby
#require_relative File.expand_path('..') + '/lib/script_conversation'
require File.expand_path('../../lib/script_conversation', __FILE__)
require 'chronic'

conversation do
  ask :when_to_cut_hair, 'Welcome to the Hair Port, Cape Cods Best Barber Shop. When are you looking for a hair cut?'
  reservation_time = Chronic.parse(when_to_cut_hair)
  record :reservation_time, reservation_time
  #hide :when_to_cut_hair
  say "Great! We are looking forward to seeing you at #{reservation_time}"
end
