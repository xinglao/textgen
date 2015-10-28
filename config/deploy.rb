require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'

SERVER = {
  "textgentest" => '166.78.181.170',
  "textgendemo" => '166.78.155.19',
  "textgenprod" => ['198.199.118.17', '198.199.101.154']
}

set :domains, Array(SERVER.fetch(ENV['on']))
set :deploy_to, '/var/www/textgen'
set :repository, 'git@github.com:graves/textgen.git'
set :branch, 'master'

set :shared_paths, ['.env', 'scripts']

set :user, 'deployer'
set :port, '22'

task :environment do
  invoke :'rbenv:load'
end

desc "Deploys the current version to the server."
task :deploy do
  isolate do
    domains.each do |domain|
      puts "deploying to domain #{domain}"
      set :domain, domain
      invoke :_deploy
      run!
    end
  end
end

task :_deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue "bundle install"

    to :launch do
      invoke :restart
    end
  end
end

desc "Restart upstart process"
task :restart do
  queue 'sudo stop textgen; sudo start textgen'
end
