Capistrano::Configuration.instance(:must_exist).load do 
  namespace :encryption do
    desc "Creates encryption.yml connection file for L7 security" 
    task :setup, :roles => :app do
      set :encryption_key do
        Capistrano::CLI.password_prompt "Enter #{environment} data encryption key: "
      end    

      key_config = <<-KEY
  #{environment}:
    user_key: #{encryption_key}
      KEY

      run "sudo mkdir -p #{shared_path}/config"
      put key_config, "/tmp/encryption.yml"
      run "sudo mv -f /tmp/encryption.yml #{shared_path}/config/encryption.yml"
    end
    
    task :symlink, :roles => :app, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/encryption.yml #{latest_release}/config/encryption.yml"
    end

    after "encryption:setup", "encryption:symlink"
    after "deploy:finalize_update", "encryption:symlink"
  end
end