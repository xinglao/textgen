class Conversation

  END_OF_MESSAGE_PATTERN = /<\/eom>/
  START_CONVERSATION_PATTERN = /^.*<conversation>/m
  END_CONVERSATION_PATTERN = /<\/conversation>.*$/m
  SCRIPT_DIR    = './scripts'
  SESSION_DIR   = './tmp/sessions'

  def self.prepare_directories
    `mkdir -p #{SESSION_DIR}`
    `mkdir -p #{SCRIPT_DIR}`
  end

  def self.find_or_create(script, user_id)
    inst = self.new
    inst.user_id = user_id
    inst.script = File.join(SCRIPT_DIR, script)
    inst.open if inst.closed?
    inst
  end

  attr_accessor :user_id, :script

  def initialize
    self.class.prepare_directories
  end

  def open
    `tmux new-session -s #{session_name} -d`
    `tmux pipe-pane -o -t #{session_name} 'cat >> #{session_log}'`
    send_keys(script)
  end

  def write(message)
    puts 'received message:' + message
    @last_message = message
    send_keys(message)
  end

  def read
    `touch #{session_log}`
    output = ""
    File.open(session_log, "r+") do |output_file|
      loop do
        output += output_file.read

        puts output
        puts 'breaking eom found' if end_of_message?(output) or end_of_conversation?(output)
        break if end_of_message?(output) or end_of_conversation?(output)
        sleep(0.01)
      end
    end
    truncate_log
    close if end_of_conversation?(output)
    output.gsub!(START_CONVERSATION_PATTERN,'')
    output.gsub!(END_CONVERSATION_PATTERN,'</session>')
    #output.gsub!(END_OF_MESSAGE_PATTERN,'')
    output[@last_message] = '' if @last_message
    output
  end

  def send_keys(command)
    `tmux send-keys -t #{session_name} '#{command}' C-m`
  end

  def close
    `tmux kill-session -t #{session_name}`
  end

  def closed?
    self.open? == false
  end

  def open?
    system("tmux has-session -t #{session_name}")
  end

private

  def end_of_conversation?(message)
    message =~ END_CONVERSATION_PATTERN
  end

  def end_of_message?(message)
    message =~ END_OF_MESSAGE_PATTERN 
  end

  def session_name
    @session_name ||= (File.basename(script) + '-' + user_id).gsub(/\W+/,'-')
  end

  def session_log
    File.join(SESSION_DIR, session_name)
  end

  def truncate_log
    `> #{session_log}`
  end

end
