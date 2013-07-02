require 'json'
require 'chronic'

DELIM = '</eom>'

def conversation(&block)
  c = ScriptConversation.new
  $stdin.gets
  begin
    c.instance_eval(&block)
  rescue Exception => e
    c.say 'Sorry, there was an error with your request. Please try again later...'
    c.say <<EOM 
      <error> 
        #{e.message}
        #{e.backtrace}  
      </error>
EOM
  end
  c.say '</conversation>'
end

class ScriptConversation
  attr_accessor :result_set

  def initialize
    @src, @dest, @script = ARGV
    @result_set = {}
  end

  def say(message)
    json = {
        :message => message,
        :as => :info,
        :input_set => @result_set
      }.to_json
    puts(json)
    STDOUT.flush
  end

  def ask(field, message, args={})
    # message <?>{}
    as = args[:as] || :text
    collection = args[:collection]

    valid = false
    tries = 0

    while !valid and tries < 5
      valid = true
      pattern = args[:pattern] || /^.+/
      conversion = nil

      #what type of apples?</eom> {ui_options: {type: 'collection', options: [1,2,3]} ,'input_set': {:num_apples => 5}}
      #say message + DELIM + @result_set.to_json

      json = {
        :message => message,
        :as => as,
        :collection => collection,
        :input_set => @result_set
      }.to_json

      puts json
      STDOUT.flush

      response = $stdin.gets.strip

      exit if response == 'quit'

      if response.start_with?("<recording>")
        valid = true
      else
        case as
        when :boolean
          true_regex = /^(t(rue)?|y(es)?|1)$/
          false_regex = /^(f(alse)?|no?|2|0)$/
          if response =~ true_regex
            conversion = -> r {
              true
            }
            valid = true
          elsif response =~ false_regex
            conversion = -> r {
              false
            }
            valid = true
          else
            valid = false
          end
        when :number
          conversion = -> r {r.to_i}
          pattern = /\d+/
          valid = response =~ pattern
        when :email
          pattern = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
          valid = response =~ pattern
        when :phone_number
          #TODO
        when :date, :datetime
          parsed_time = Chronic.parse(response)
          valid = !parsed_time
          .nil?
          conversion = -> r {
            as == :date ? parsed_time.to_date : parsed_time
          }
        when :select
          valid = collection.include?(response.downcase)
        when :text
          valid = response =~ pattern
        end
      end

      tries += 1
      if valid
        response = conversion.call(response) unless conversion.nil?
        break
      end

      say "you did not enter it correctly, please try again..."
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
