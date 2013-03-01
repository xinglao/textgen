def conversation(&block)
  puts '<conversation>'
  c = Conversation.new
  c.instance_eval(&block)
  puts '</conversation>'
end

class Conversation
  attr_accessor :result_set

  def initialize
    @result_set = {}
  end

  def say(message)
    puts message
  end

  def ask(field, message, args={})

    delim = '</?>'
    as = args[:as]

    valid = false
    tries = 0

    while !valid and tries < 5
      valid = true
      pattern = /^.+/
      conversion = nil

      say message + delim
      response = $stdin.gets.strip

      exit if response == 'quit'

      unless as.nil?
        case as
          when :number
            conversion = -> r {r.to_i}
            pattern = /\d+/
          when :email
            pattern = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
          when :phone_number
            #TODO
          when :date
            #TODO
          when Regexp
            pattern = as
          else
            raise 'You have entered an incorrect :as value'
        end
      end

      valid = response =~ pattern

      tries += 1
      if valid
        response = conversion.call(response) unless conversion.nil?
        break
      end

      puts "you did not enter it correctly, please try again..."
    end

    @result_set[field] = response

    self.class.send(:define_method, field) do
      response
    end
  end

  def confirm
    say "confirm...?"
  end

end
