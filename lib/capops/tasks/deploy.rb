Capistrano::Configuration.instance(:must_exist).load do 
  set :stages, %w(production staging)
  set :default_stage, "staging"
  set :shared_folders, %w(log config)
  
  namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end

    desc "Create new web server installation"  
    task :create, :roles => :web do  
      run "sudo locale-gen en_GB.UTF-8"
      run "sudo /usr/sbin/update-locale LANG=en_GB.UTF-8"
      run "sudo add-apt-repository -y ppa:chris-lea/node.js"
      run "sudo apt-get -y update"
      run "sudo apt-get -y upgrade"
      run "sudo apt-get -y install build-essential"
      run "sudo apt-get -y install python-software-properties"
      run "sudo apt-get -y install libpcre3 libpcre3-dev"
      run "sudo apt-get -y install zlib1g-dev"
      run "sudo apt-get -y install openssl"
      run "sudo apt-get -y install libopenssl-ruby1.9.1"
      run "sudo apt-get -y install libssl-dev"
      run "sudo apt-get -y install libcurl4-openssl-dev"
      run "sudo apt-get -y install libxml2"
      run "sudo apt-get -y install libxml2-dev"
      run "sudo apt-get -y install libxslt-dev"
      run "sudo apt-get -y install libyaml-dev"
      run "sudo apt-get -y install libruby1.9.1"
      run "sudo apt-get -y install libreadline-dev"
      run "sudo apt-get -y install git-core"
      run "sudo apt-get -y install nodejs"
      run "sudo apt-get -y install ruby1.9.3"

      passenger.setup
      bundle.setup
      rails.setup
      log.setup
      deploy.setup_app_directory
      deploy.setup_shared_folders
      db.setup
      ec2.setup
      deploy.cold
      upstart.setup
    end
    
    task :setup_app_directory, :roles => :app do
      run "if [ ! -d '#{deploy_to}' ]; then sudo mkdir #{deploy_to}; fi"
      run "sudo chown #{user}:root #{deploy_to}"
    end

    task :setup_shared_folders, :roles => :app, :except => { :no_release => true } do
      commands = shared_folders.map do |folder| 
        path = "#{shared_path}/#{folder}"
        "if [ ! -d '#{path}' ]; then mkdir -p #{path}; fi"
      end
      run commands.join(" && ")
    end    
  end
end