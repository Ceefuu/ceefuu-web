# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "ceefuu"
set :repo_url, "git@github.com:Ceefuu/ceefuu-web.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  
    desc 'Automatically skip asset compile if possible'
    task :auto_skip_assets do
      asset_locations = %r(^(Gemfile\.lock|app/assets|lib/assets|vendor/asset))
  
      revisions = []
      on roles :app do
        within current_path do
          revisions << capture(:cat, 'REVISION').strip
        end
      end
  
      # Never skip asset compile when servers are running on different code
      next if revisions.uniq.length > 1
  
      changed_files = `git diff --name-only #{revisions.first}`.split
      if changed_files.grep(asset_locations).none?
        puts Airbrussh::Colors.green('** Assets have not changed since last deploy.')
        invoke 'deploy:skip_assets'
      end
    end
  
    desc 'Skip asset compile'
    task :skip_assets do
      puts Airbrussh::Colors.yellow('** Skipping asset compile.')
      Rake::Task['deploy:assets:precompile'].clear_actions
    end
  
end