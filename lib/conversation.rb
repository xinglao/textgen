class Conversation

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
    send_keys(message)
  end

  def read
    `touch #{session_log}`
    output = ""
    File.open(session_log, "r+") do |output_file|
      loop do
        output += output_file.read
        break if end_of_message?(output) or quit_conversation?(output)
      end
    end
    truncate_log
    close if output =~ /<\/\$>\s*$/ 
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

  def quit_conversation?(message)
    message =~ /<\/\$>\s*$/ 
  end

  def end_of_message?(message)
    message =~ /<\/\?>\s*$/
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
