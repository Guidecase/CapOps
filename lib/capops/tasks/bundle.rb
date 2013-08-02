Capistrano::Configuration.instance(:must_exist).load do 
  namespace :bundle do
    desc "Installs bundler gem on the app server"
    task :setup, :roles => :app do
      run "if ! gem list | grep --silent -e 'bundler'; then sudo gem uninstall bundler; sudo gem install --no-rdoc --no-ri bundler; fi"
    end

    task :install, :roles => :app, :except => { :no_release => true } do
      run "cd #{release_path} && bundle install --local --without=development test"
    end    

    task :pack, :roles => :app, :except => { :no_release => true } do
      run_locally "if [ -d 'vendor/cache' ]; then rm -r vendor/cache; fi"
      system "bundle update && bundle install"
      system "bundle package --all"
    end    
  end
end