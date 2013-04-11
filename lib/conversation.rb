class Conversation

  END_OF_MESSAGE_PATTERN = /<\/eom>/
  START_CONVERSATION_PATTERN = /^.*<conversation>/m
  END_CONVERSATION_PATTERN = /<\/conversation>.*$/m
  SCRIPT_DIR    = '/home/subout/code/textgen/scripts'

  attr_accessor :user_id, :script

  def initialize(user_id, script, version, url)
    user_id = user_id
    assign_script(script, version, url)
  end

  def assign_script(script, version, url)
    ext = File.extname(script)
    script.gsub!(ext,'')
    name = (script + '_' + version.to_s).gsub(/[^_\w\.]+/, '_').downcase
    name += ext
    final = File.join(SCRIPT_DIR, name)
    puts url
    puts final
    unless File.exist? final
      `curl #{url} > #{final}`
      `chmod +x #{final}`
    end

    self.script = final
  end

    #{ "command": "/home/subout/code/textgen/scripts/scrump_1.rb" , "dataLine": "h", "uuid": "self.user_id" }

  def script_daemon_json(message)
    { 
      command: self.script,
      dataLine: message,
      uuid: self.user_id 
    }
  end

  def write(message)
    return if message.blank?
    File.open("/var/tmp/scriptserver.in", "w+") do |f|
      f.puts script_daemon_json(message)
      f.flush 
    end
  end

  def read
    output = ""
    File.open("/var/tmp/scriptserver.out", "r+") do |output_file|
      loop do
        #TODO ask tom what we should do if they never send delimiter
        output += output_file.gets
        puts output
        if end_of_message?(output) or end_of_conversation?(output)
          puts 'breaking eom found' 
          break 
        end
      end
    end

    output
  end

private

  def end_of_conversation?(message)
    message =~ END_CONVERSATION_PATTERN
  end

  def end_of_message?(message)
    message =~ END_OF_MESSAGE_PATTERN 
  end
end
