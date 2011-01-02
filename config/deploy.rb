#	APPLICATION DETAILS #######################################

# name of the application
set :application, "aisforarray" # this will be used to create the folder structure (see line)
set :deploy_to, "/sites/brandon/aisforarray.com"

#default_run_options[:pty] = true
#default_run_options[:shell] = false

# Since this will rollout our code to the production server, state so explicitely:
#set :rails_env, "production"

#	GETTING INTO THE PRODUCTION SERVER ########################

# username of the user underwhich capistrano will log in,
# in this case, this is the deploy user we created earlier
set :user, "root"

# the deploy user has all the required permissions, so sudo is not needed
set :use_sudo, false

# you may, or may not need to use this - but let's use it just in case
ssh_options[:paranoid] = false

# address of the production server, not that this is a variable
set :domain, "173.255.209.57" #"IP or domain name of production server"

# the above variable is used here.
# however, you can write these out - and may need to if you set up your environment
# in a way that puts these things on different servers
# however, in our exaple, everything is on the same server, so using the variable makes sense
role :app, domain
role :web, domain
role :db, domain, :primary => true

#	GIT AND GITHUB ############################################

# tell Capistrano that our version control is done with Git
set :scm, :git

# address of our Git repository, which happens to be on Github
# NOTE: the format of this is git@github.com:your_user_name/git_repository_name.git
#set :repository,  "git@github.com:monolith/rollout_tutorial.git"
set :repository,  "git://github.com/ready4god2513/a-is-for-public.git"

# don't forget to change the above user name to yours!

# in Git, you can have many branches.  To stay consistent with the defaults (and out example), we are using master
set :branch, "master"

# this command means that only the changes will be updated (not entire code base)
set :deploy_via, :remote_cache

# where is the git command on the server?  stating it just in case
set :scm_command, "git"

# TASKS #####################################################

# there are some things we'll want to do after the basic deployment has completed
# to do those things, we will create the tasks, and then call them in the end

# until this point, all the code that has been deployed, matches what you have in the (Github) repository
# since we excluded the config directory from our Git versioning (in order to not display or details publically on Github)
# we need to copy the files over to the production server

namespace :deploy do

  desc "Sync the config directory"
  task :sync_config do
    # this will sync files on your local machine with that on your production server
    # we need this for the files that we told git to ignore

    # notice that the domain variable is used (this should be the ip or domain of your app)
    # we set this variable way on top
    # also note that this is going to the shared folder, the symlink task below will link these from the release folder

    # make sure you install rsync on the server
    #system "rsync -vr --exclude='*~' config #{user}@#{domain}:#{release_path}/"

    # we'll need the tmp file to restart Passenger (see below)
    system "rsync -vr --exclude='*~' tmp #{user}@#{domain}:#{shared_path}/"

    # and also let's sync the db folder - notice this goes in the current folder
    #system "rsync -vr --exclude='*~' db #{user}@#{domain}:#{release_path}/"

  end

  desc "Fix permissions and set environment after code update."
  task :update_permissions, :roles => [:app, :db, :web] do
    # set permissions
    run "chmod -R 777 #{release_path}/public"
  end


  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{release_path}/tmp/restart.txt"
  end

  desc "Run bundler command for installing gems"
  task :bundler, :roles => :app do
    # run "cd #{release_path}"
    #     run "bundle install"
  end


  # Note that the default deploy:start task looks for a script/spin script
  # to run. If you are using a deployment method that doesn't need script/
  # spin, then you'll need to override deploy:start
  # http://www.mail-archive.com/capistrano@googlegroups.com/msg04819.html
  deploy.task :start do
     # nothing
   end
end

after 'deploy:update_code', 'deploy:sync_config', 'deploy:update_permissions', 'deploy:restart'
after "deploy:update_code", "deploy:bundler"