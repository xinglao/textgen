require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'

SERVER = {
  "test" => '166.78.181.170',
  "demo" => '166.78.155.19'
}

set :domain, SERVER.fetch(ENV['on'])
set :deploy_to, '/var/www/textgen'
set :repository, 'git@github.com:suboutdev/textgen.git'
set :branch, 'master'

set :shared_paths, ['.env', 'scripts']

set :user, 'deployer'
set :port, '22'

task :environment do
  invoke :'rbenv:load'
end

desc "Deploys the current version to the server."
task :deploy => :environment do
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
