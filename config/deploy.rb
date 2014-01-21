#OPTIMIZE improve speed of deploing
#TODO make elegant exit unicorn restart and stop
#TODO lock cap version

set :application, 'art-electronics'
set :user, 'www'
set :scm, :git
set :repo_url, 'git@github.com:taichiman/open-cook.git'
set :deploy_to, -> { "/var/www/#{ fetch :application }/#{ fetch :stage }" }

set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :format, :pretty
set :log_level, :debug
set :pty, true

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { rails_env: 'production' }

set :keep_releases, 5
set :ssh_options, {:forward_agent => true}

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.1.0@art-electronics'

set :unicorn_conf, -> { "#{fetch :deploy_to}/current/config/unicorn.rb" }
set :unicorn_pid, -> { "#{fetch :deploy_to}/shared/tmp/pids/unicorn.pid" }
set :unicorn_binary, "unicorn_rails"

role :web, %w{www@107.170.254.124}
role :app, %w{www@107.170.254.124}
role :db , %w{www@107.170.254.124}
server '107.170.254.124', user: 'www', roles: %w{web app db}

set :rake,           "rake"
set :rails_env,      "production"
set :migrate_env,    ""
set :migrate_target, :latest


namespace :deploy do

  desc 'Restart application'
  task :restart do
    # on roles(:app) do
      invoke 'deploy:unicorn:restart'
    # end
  end

  namespace :unicorn do
    
    pid_path = "#{fetch :release_path}/tmp/pids"
    unicorn_pid = "#{pid_path}/unicorn.pid"

    desc 'Start unicorn'
    task :start do
      on roles(:app) do
        within current_path do
          with rails_env: fetch(:rails_env) do
            execute :bundle, "exec #{fetch(:unicorn_binary)} -c #{fetch :unicorn_conf} -E #{fetch :rails_env} -D"
          end
        end
      end
    end

    desc 'Stop unicorn'
    task :stop do
      on roles(:app) do
        execute "if [ -f #{fetch :unicorn_pid} ] && [ -e /proc/$(cat #{fetch :unicorn_pid}) ]; then kill `cat #{fetch :unicorn_pid}`; fi"
      end
    end

    desc 'Restart unicorn'
    task :restart do
      on roles(:app) do
        on roles(:app) do
          execute "if [ -f #{fetch :unicorn_pid} ] && [ -e /proc/$(cat #{fetch :unicorn_pid}) ]; then kill `cat #{fetch :unicorn_pid}`; fi"
        end

        on roles(:app) do
          within current_path do
            with rails_env: fetch(:rails_env) do
              execute :bundle, "exec #{fetch(:unicorn_binary)} -c #{fetch :unicorn_conf} -E #{fetch :rails_env} -D"
            end
          end
        end
      end
    end

  end

  after :finishing, 'deploy:cleanup'

end

desc "run on server"
task :run_on do
  on roles :app do
    execute "id"
  end
end