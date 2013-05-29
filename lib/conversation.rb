class Conversation

  END_OF_MESSAGE_PATTERN = /<\/eom>/
  START_CONVERSATION_PATTERN = /^.*<conversation>/m
  END_CONVERSATION_PATTERN = /<\/conversation>.*$/m
  SCRIPT_DIR    = ENV['SCRIPT_DIR']

  attr_accessor :user_id, :script

  def initialize(user_id, script, version, url)
    self.user_id = user_id
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
      `curl #{url} -o #{final} -f`
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
    }.to_json
  end

  def write(message)
    File.open("/var/tmp/scriptserver.in", "w+") do |f|
      puts script_daemon_json(message)
      f.puts script_daemon_json(message)
      f.flush 
    end
  end

  def self.end_of_conversation?(message)
    message =~ END_CONVERSATION_PATTERN
  end

  def self.end_of_message?(message)
    message =~ END_OF_MESSAGE_PATTERN 
  end

  def self.handle_message(msg)
    puts msg
    params = JSON.parse(msg)

    convo = Conversation.new(
      params['user_id'],
      params['script'],
      params['script_version'],
      params['script_url']
    )
    message = params['message']

    puts 'writing input:' + message.to_s
    convo.write(message)
  end
end
