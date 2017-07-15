#set :assets_roles, fetch(:asset_roles, []).push('ws')
# If the environment differs from the stage name
set :rails_env, 'production'
set :site_name, 'ws'

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}


append :linked_files, 'vendor/gems/authengine/app/views/authengine/user_mailer/signup_notification.en.html.erb'

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
 set :ssh_options, {
   keys: %w(/Users/lesnightingill/.ssh/oodb_server_keys/id_rsa),
   forward_agent: false,
   auth_methods: %w(publickey)
 }

# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
server 'ws',
  user: 'deploy',
  roles: %w{web app},
  ssh_options: {
    user: 'deploy', # overrides user setting above
    keys: %w(/Users/lesnightingill/.ssh/oodb_server_keys/id_rsa),
    forward_agent: false,
    auth_methods: %w(publickey)
    # password: 'please use keys'
  }

#set :rvm_custom_path, "~/.rvm"

# could not get whenever gem's own update_crontab to work
# as the release path was not set, so use this workaround
namespace :deploy do
 task :update_crontab do
   on roles(:all) do
     within current_path do
       execute :bundle, :exec, :whenever, "--update-crontab", "~/var/www/nhri_docs/current/config/schedule.rb"
     end
   end
 end
end
after 'deploy:symlink:release', 'deploy:update_crontab'
