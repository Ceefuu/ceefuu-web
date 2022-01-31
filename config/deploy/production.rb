#FIXME replace 1.2.3.4 with your IP address
server '34.224.81.193', user: 'deploy', roles: %w{web app db}
set :rails_env, 'production'