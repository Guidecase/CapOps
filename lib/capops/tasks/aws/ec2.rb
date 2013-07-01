Capistrano::Configuration.instance(:must_exist).load do 
  cset :aws_local_config, "#{templates_path}/rails/aws.yml.erb"
  cset :aws_remote_config, "#{shared_path}/config/aws.yml"
  cset :aws_release_config, "#{current_path}/config/aws.yml"  

  cset :ec2_user_key_path, "~/.ec2/pk-#{application}.pem"
  cset :ec2_user_cert_path, "~/.ec2/cert-#{application}.pem"

  namespace :ec2 do
    task :setup, :roles => :app do
      set(:access_key_id) { Capistrano::CLI.ui.ask "Enter #{environment} AWS access key id:" }
      set(:secret_access_key) { Capistrano::CLI.password_prompt "Enter #{environment} AWS secret access key:" }
    
      generate_file aws_local_config, aws_remote_config
    end
    
    task :symlink, :except => { :no_release => true } do
      run "if [ -d #{current_path} ]; then ln -nfs #{aws_remote_config} #{aws_release_config}; fi"
    end   
  end
end