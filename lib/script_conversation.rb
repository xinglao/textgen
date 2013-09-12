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
    File.open('/tmp/gordon.txt', 'w+') { |file| file.write(e.message) }
    File.open('/tmp/gordon.txt', 'w+') { |file| file.write(e.backtrace) }
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
    @src, @dest, @script, @mode, @initial_message = ARGV
    @result_set = {}
  end

  def say(message)
    json = {
      :message => message,
      :as => :info,
      :input_set => @result_set
    }
    echo(json.to_json)
  end

  def human!(message = 'Starting chat session... We will be with you shortly...')
    message = {
      :human => true,
      :message => message,
      :as => :info,
      :input_set => @result_set
    }
    echo(message.to_json)

    $stdin.gets.strip #block so that we don't continue script till they exit human mode
  end

  def echo(message)
    puts(message)
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
          response = "" if response.nil?
          response.downcase!
          true_regex = /^(t(rue)?|y(es)?|1)$/i
          false_regex = /^(f(alse)?|no?|2|0)$/i
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
          pattern = /\d+/
          valid = response =~ pattern and response.length == 10
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
