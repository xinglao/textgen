#!/usr/bin/env ruby
require File.expand_path('..') + '/lib/script_conversation'

def current_balance
  # Any Ruby code to connect out to external systems.
  # Would know the account number, and look this up in the database
  (rand(100)*1.21).to_s
end
def confirm_account(session_from_number)
  # Any Ruby code to connect out to external systems.
  # Would do the security checks through LDAP, etc.
  true
end


conversation do
  session_from_number = "15083649972" # Just for testing
  if confirm_account(session_from_number) then
    ask :service, 
      'Thanks for being a customer! Because your cell phone is authorized by our company, 
       theres no need to login. balance, payments, orders?', :as => /(balance|payments|orders)/
    case service.downcase
    when "balance"
      say "Your current account balance is #{current_balance}"
    when "payments"
      ask :pay_now, "Your last payment was never. Text back y to pay your current balance of #{current_balance}from your stored credit card."
      if pay_now == 'y' then
        say "Thank you!!!"
      else
        say "What?"
      end
    when "orders"
      say "Your order is benedictine."
    end
  else
    say "Your phone is not a phone that's authorized by our company. Please press send to talk to us!"
  end
end