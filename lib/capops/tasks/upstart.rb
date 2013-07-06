Capistrano::Configuration.instance(:must_exist).load do 
  cset :upstart_nginx_local_config, "#{templates_path}/upstart/nginx.conf.erb"
  cset :upstart_nginx_remote_config, "/etc/init/nginx.conf"

  cset :upstart_dj_local_config, "#{templates_path}/upstart/delayed_job.conf.erb"
  cset :upstart_dj_remote_config, "/etc/init/delayed_job.conf"

  namespace :upstart do
    desc "Creates upstart conf files for nginx and delayed job."
    task :setup, :roles => :app, :except => { :no_release => true } do
      upstart.delayed_job
      upstart.nginx
    end

    task :delayed_job, :roles => :app, :except => { :no_release => true } do
      generate_file upstart_dj_local_config, upstart_dj_remote_config
      run "sudo chown root:root #{upstart_dj_remote_config}"
    end

    task :nginx, :roles => :app, :except => { :no_release => true } do
      generate_file upstart_nginx_local_config, upstart_nginx_remote_config
      run "sudo chown root:root #{upstart_nginx_remote_config}"
    end    

    task :cleanup, :roles => :app, :except => { :no_release => true } do
      run "sudo rm #{upstart_nginx_remote_config} && sudo rm #{upstart_dj_remote_config}"
    end

    task :status, :roles => :app, :except => { :no_release => true } do
      run "status nginx"
      run "status delayed_job"
    end

    desc "Checks the status of nginx and delayed job conf files."
    task :check, :roles => :app, :except => { :no_release => true } do
      run "initctl check-config nginx --warn"
      run "initctl check-config delayed_job --warn"
    end
  end
end