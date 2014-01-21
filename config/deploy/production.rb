set :deploy_to, -> { "/home/#{fetch :user}/#{fetch :application}/#{fetch(:stage)}" }
set :stage, :production
# set :branch, :master