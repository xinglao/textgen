require 'json'
require 'chronic'
require 'dotenv'
require 'redis'
require 'rest_client'

class ResponseNotUnderstood < StandardError; end

DELIM = '</eom>'

def conversation(&block)
  c = ScriptConversation.new
  $stdin.gets
  begin
    c.instance_eval(&block)
  rescue ResponseNotUnderstood => e
    c.say '</conversation>'
    return
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

    begin
      Dotenv.load("/var/www/textgen/current/.env")
      $redis = Redis.new
      key = @dest + "_settings"

      settings = $redis.get(key)
      if settings
        @settings = JSON.parse(settings)
      else
        @settings = nil
      end
    rescue => detail
      print detail.backtrace.join("\n")
    end
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

      error_string = "That does not match the type of data we are looking for. Please try again..."

      if response.start_with?("<recording>")
        valid = true
      else
        case as
        when :boolean
          response = "" if response.nil?
          response.delete('^a-zA-Z0-9')
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
            error_string = "Sorry, we're looking for a yes or a no. Please try again."
          end
        when :number
          conversion = -> r {r.to_i}
          pattern = /\d+/
          valid = response =~ pattern
          error_string = "Sorry, we're looking for a whole number. Please try again." unless valid
        when :email
          pattern = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
          valid = response =~ pattern
          error_string = "Sorry, we're looking for a valid email. Please try again." unless valid
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
          valid = collection.map(&:downcase).include?(response.downcase)
          error_string = "Sorry, we're looking for one of the following choices:  #{collection.join(",")}. Please try again." unless valid

        when :text
          valid = response =~ pattern
        end
      end

      tries += 1
      if valid
        response = conversion.call(response) unless conversion.nil?
        break
      end

      say error_string
    end

    @result_set[field] = response

    self.class.send(:define_method, field) do
      response
    end
  end

  def simon_ask(field, message, args={})
    # message <?>{}
    as = args[:as] || :text
    max_tries = args[:tries] || 2
    collection = args[:collection]

    valid = false
    tries = 0

    while !valid and tries < max_tries
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

      error_string = "That does not match the type of data we are looking for. Please try again..."

      if response.start_with?("<recording>")
        valid = true
      else
        case as
        when :boolean
          response = "" if response.nil?
          response.delete('^a-zA-Z0-9')
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
            error_string = "Sorry, we're looking for a yes or a no. Please try again."
          end
        when :number
          conversion = -> r {r.to_i}
          pattern = /\d+/
          valid = response =~ pattern
          error_string = "Sorry, we're looking for a whole number. Please try again." unless valid
        when :email
          pattern = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
          valid = response =~ pattern
          error_string = "Sorry, we're looking for a valid email. Please try again." unless valid
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
          valid = collection.map(&:downcase).include?(response.downcase)
          error_string = "Sorry, we're looking for one of the following choices:  #{collection.join(",")}. Please try again." unless valid

        when :text
          valid = response =~ pattern
        end
      end

      tries += 1
      if valid
        response = conversion.call(response) unless conversion.nil?
        break
      end

      say error_string unless tries == max_tries
    end

    if !valid && tries == max_tries
      @result_set[field] = response

      self.class.send(:define_method, field) do
        response
      end

      simon = SimonWeb::API::Client.new
      simon.associate_mall(@dest)
      say "We're sorry, we are having trouble understanding you. Please visit Guest Services #{simon.guest_services_location} or call #{simon.guest_services_phone} for assistance."
      raise ResponseNotUnderstood.new
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
    self.class.send(:define_method, field) do
      value
    end
  end

  def email(recipient, subject, text)
    RestClient.post "https://api:key-2nuu4xauscga1cpnpr-tr3pf0ykkljx2@api.mailgun.net/v2/mail.textgen.com/messages",
      :from => "noreply@mail.textgen.com",
      :to => recipient,
      :subject => subject,
      :text => text 
  end
end
