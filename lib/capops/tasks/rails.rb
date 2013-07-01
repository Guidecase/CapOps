Capistrano::Configuration.instance(:must_exist).load do 
  namespace :rails do
    desc "Installs Rails gem"
    task :setup, :roles => :app do
      run "sudo gem install rails"
    end    
 
    desc "Updates Rails gem"
    task :update, :roles => :app do
      run "sudo gem update rails"
    end 
  end

  after "deploy:cold", "encryption:setup"
  after "deploy:cold", "db:setup"
  after "deploy:cold", "ec2:setup"
end