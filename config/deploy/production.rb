#FIXME replace 1.2.3.4 with your IP address
server '34.224.81.193', user: 'deploy', roles: %w{web app db}

 set :ssh_options, {
   keys: %w(/home/deploy/.ssh/id_rsa),
   forward_agent: false,
   auth_methods: %w(password)
 }
 
set :rails_env, 'production'