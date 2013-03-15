require 'json'

DELIM = '</eom>'

def conversation(&block)
  puts '<conversation>'
  c = ScriptConversation.new
  c.instance_eval(&block)
  puts DELIM + c.result_set.to_json
  puts '</conversation>'
end

class ScriptConversation
  attr_accessor :result_set

  def initialize
    @result_set = {}
  end

  def say(message)
    puts message
  end

  def ask(field, message, args={})
    # message <?>{}
    as = args[:as]

    valid = false
    tries = 0

    while !valid and tries < 5
      valid = true
      pattern = /^.+/
      conversion = nil

      say message + DELIM + @result_set.to_json
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

  def hide item
    case item
    when Array
      item.each do |i|
        @result_set.delete(i)
      end
    else
      @result_set.delete(item)
    end
  end

  def record(field, value) 
    @result_set[field] = value
  end
end
