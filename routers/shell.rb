#!/usr/bin/env ruby
require_relative 'app'

class Shell 
  SCRIPTS = {
    "order apples" => "scrump.rb"
  }

  def self.run
    sessions = {}
    while true
      input = gets
      user, *message = input.split(" ")
      message = message.join(" ")

      session[user] ||= {} 
      session[user][:script] ||= SCRIPTS[message]
      unless session[user][:thread]
        session[user][:thread] = Thread.new(input_pipe_name, output_pipe_name) do |input_pipe_name, output_pipe_name|
          c = Conversation.new(input_pipe_name, output_pipe_name)
          c.run(session[user][:script])
        end
      end
      session[user][:thread].join
    end
  end
end

Shell.run

>
>routers/shell
>gordon order apples
>
>

script_dir = File.expand_path('./scripts')
script_path = File.join(script_dir, script_name + '.rb')

puts "creating thread"
puts script_path

script = Thread.new do
  require script_path
end
script.join

