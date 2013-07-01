Capistrano::Configuration.instance(:must_exist).load do 
  namespace :bundler do
    desc "Installs bundler gem on the app server"
    task :setup, :roles => :app do
      run "if ! gem list | grep --silent -e 'bundler'; then sudo gem uninstall bundler; sudo gem install --no-rdoc --no-ri bundler; fi"
    end
  end
end