def conversation(&block)
  app = ConversationText.new
  app.instance_eval(&block)
  puts app.result_set
end

class ConversationText
  attr_accessor :result_set

  def initialize 
    @result_set = {}
  end

  def say(message)
    puts message
  end

  def ask(field, message, args={})
    as = args[:as]

    valid = false
    tries = 0
    while !valid and tries < 5
      valid = true

      puts message
      response = gets

      case as
        when :number
          if response =~ /\d+/
            response = response.to_i
          else
            valid = f
          end
        when :email
          regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
          unless response =~ regex
            valid = false
          end
        when :phone_number
        when :date
        else
      end

      tries += 1
      break if valid

      puts "you did not enter it correctly, please try again..."
    end

    @result_set[field] = response

    self.class.send(:define_method, field) do
      response
    end
  end
end

