require 'pry'
require 'sinatra'

get '/spawn' do
  script = params[:script]
  session = session_from_params(params)
  session_log = "tmp/sessions/#{session}.log"
  `tmux new-session -s #{session} -d`
  `tmux pipe-pane -o -t #{session} 'cat >> #{session_log}'`
  `touch #{session_log}`
  `tmux send-keys -t #{session} 'scripts/#{script}' C-m`
  puts `tmux list-sessions`
  read_output(session_log)
end

get '/message' do
  session = session_from_params(params)
  message = params[:message]

  `tmux send-keys -t #{session} '#{message}' C-m`

  output = read_output("tmp/sessions/#{session}.log")
  `tmux kill-session -t #{session}`
  if output =~ /<\/\$>\s*$/ 
  output
end

def session_from_params(params)
  (params[:script] + params[:user_id]).gsub(/\W+/,'-')
end

def read_output(session_log)
  output = ""
  open(session_log, "r+") do |output_file|
    loop do
      output += output_file.read
      break if output =~ /<\/\?>\s*$/ || output =~ /<\/\$>\s*$/ 
    end
  end
  `> #{session_log}`
  output
end
