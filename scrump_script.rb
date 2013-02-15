require_relative 'app'

conversation do
  say 'hello' 
  
  number_of_apples = type_of_apple = 0

  while number_of_apples > 9 and type_of_apple == "green"
    ask :number_of_apples, "how many apples do you want?", :as => :number, :optional => true
    ask :type_of_apple, "What type of apple do you want?"
    say "umm we don't have that many green apples sorry"
  end

  if number_of_apples > 10
    say "man that's a lot of apples"
  else
    say "is that all?"
  end
  
  
  ask :email_address, "What is your email address?", :as => :email


  #ask :postal_code, "Enter your postal code", :pattern => /[A-Z][0-9][A-Z]\ ?[0-9][A-Z][0-9]/, :repeat_on_error => true, :error_message => 'nooooo'
  
  say 'goodbye'
end
