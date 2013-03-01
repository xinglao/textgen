class Conversation

  STORAGE_DIR = './pipe'

  def self.find_or_create(user_id, script)
    inst = self.new
    inst.user_id = user_id
    inst.script = script
    inst.open if inst.closed?
    inst
  end

  attr_accessor :user_id, :script

  def open
    `touch #{session_log}`
    `tmux new-session -s #{session_name} -d`
    `tmux pipe-pane -o -t #{session_name} 'cat >> #{session_log}'`
    send_keys(script)
  end

  def write(message)
    send_keys(message)
  end

  def read
    output = ""
    open(session_log, "r+") do |output_file|
      loop do
        output += output_file.read
        break if output =~ /<\/\?>\s*$/ || output =~ /<\/\$>\s*$/ 
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

  def session_name
    @session_name ||= (script + '-' + user_id).gsub(/\W+/,'-')
  end

  def session_log
    File.join(STORAGE_DIR, session_name)
  end

  def truncate_log
    `> #{session_log}`
  end

end
