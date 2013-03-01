require 'pry'
require 'pty'

id        = ARGV[0]
fifo_in   = ARGV[1]
fifo_out  = ARGV[2]
script    = ARGV[3]

fifo_input  = File.open(fifo_in, 'r+')
fifo_output = File.open(fifo_out, 'w+')
pty_output, pty_input, pty_pid = PTY.spawn("ruby #{script}")

def message(pty_output)
  blocked_4_input_regex = /<\/\?>/
  buffer = ''
  loop do
    last_input = pty_output.readline
    exit if last_input =~ /confirm/
    if last_input =~ blocked_4_input_regex
      last_input.gsub!(blocked_4_input_regex, '')
      buffer << last_input
      break
    else
      buffer << last_input
    end
  end

  return buffer
end

begin
  system "stty -echo"
  loop do
    fifo_output.puts message(pty_output)
    input_message = fifo_input.gets
    pty_input.write(input_message)
  end
ensure
  system "stty echo"
end
