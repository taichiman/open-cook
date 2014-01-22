#TODO lock cap version
# for capistrano3 setup use tutorial http://www.talkingquickly.co.uk/2014/01/deploying-rails-apps-to-a-vps-with-capistrano-v3/

set :application, 'art-electronics'
set :user, 'www'

#setup repo details
set :scm, :git
set :repo_url, 'git@github.com:taichiman/open-cook.git'

#setup rvm
set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.1.0@art-electronics'

set :pty, true

#files and dirs we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

#what test should be run before deploy is allowed to continue
set :tests, ["spec"]

#which config files should be copy by deploy
set :config_files, %w(
  database.example.yml
  nginx.conf
  unicorn.rb
  unicorn_init.sh
)

#which config files should be make executable after copyng by deploy deploy:setup_config
set :executable_config_files, %w(unicorn_init.sh)

#files which need be symlinked
set(:symlinks, [
  {
    source: "nginx.conf",
    link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
  },
  {
    source: "unicorn_init.sh",
    link: "/etc/init.d/unicorn_#{fetch(:full_app_name)}"
  }
])

#join to main workflow
namespace :deploy do
  # make sure we're deploying what we think we're deploying
  before :deploy, "deploy:check_revision"
  # only allow a deploy with passing tests to deployed
  # before :deploy, "deploy:run_tests"
  # compile assets locally then rsync
  # after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  after :finishing, 'deploy:cleanup'
end

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :default_env, { rails_env: 'production' }

set :keep_releases, 5
set :ssh_options, {:forward_agent => true}


# set :unicorn_conf, -> { "#{fetch :deploy_to}/current/config/unicorn.rb" }
# set :unicorn_pid, -> { "#{fetch :deploy_to}/shared/tmp/pids/unicorn.pid" }
# set :unicorn_binary, "unicorn_rails"


# set :rake,           "rake"
# set :migrate_env,    ""
# set :migrate_target, :latest

#gem capistrano-bundler
set :bundle_flags, '--deployment'

namespace :deploy do

  # desc 'Restart application'
  # task :restart do
  #   # on roles(:app) do
  #     invoke 'deploy:unicorn:restart'
  #   # end
  # end

  # namespace :unicorn do
    
  #   pid_path = "#{fetch :release_path}/tmp/pids"
  #   unicorn_pid = "#{pid_path}/unicorn.pid"

  #   desc 'Start unicorn'
  #   task :start do
  #     on roles(:app) do
  #       within current_path do
  #         with rails_env: fetch(:rails_env) do
  #           execute :bundle, "exec #{fetch(:unicorn_binary)} -c #{fetch :unicorn_conf} -E #{fetch :rails_env} -D"
  #         end
  #       end
  #     end
  #   end

  #   desc 'Stop unicorn'
  #   task :stop do
  #     on roles(:app) do
  #       execute "if [ -f #{fetch :unicorn_pid} ] && [ -e /proc/$(cat #{fetch :unicorn_pid}) ]; then kill `cat #{fetch :unicorn_pid}`; fi"
  #     end
  #   end

  #   desc 'Restart unicorn'
  #   task :restart do
  #     on roles(:app) do
  #       on roles(:app) do
  #         execute "if [ -f #{fetch :unicorn_pid} ] && [ -e /proc/$(cat #{fetch :unicorn_pid}) ]; then kill `cat #{fetch :unicorn_pid}`; fi"
  #       end

  #       on roles(:app) do
  #         within current_path do
  #           with rails_env: fetch(:rails_env) do
  #             execute :bundle, "exec #{fetch(:unicorn_binary)} -c #{fetch :unicorn_conf} -E #{fetch :rails_env} -D"
  #           end
  #         end
  #       end
  #     end
  #   end

  # end

  # after :finishing, 'deploy:cleanup'

end

desc "run on server"
task :run_on do
  on roles :app do
    execute "id"
  end
end