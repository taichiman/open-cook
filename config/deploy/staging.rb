set :stage, :staging
set :branch, :deploy_feature

set :full_app_path, "#{ fetch :application }_#{ fetch :stage }"

server '107.170.254.124', user: 'www', roles: %w{web app db}, primary: true

set :deploy_to, -> { "/var/www/#{ fetch :full_app_path }" }

set :rails_env, "production"

set :unicorn_worker_count, 5

#whether we're using ssl or not, used for building nginx config file
set :enable_ssl, false