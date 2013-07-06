Capistrano::Configuration.instance(:must_exist).load do 
  # important - required in path, nginx won't work without correct ref
  cset :passenger_version, '4.0.5' 

  cset :nginx_tld, 'earlydoc.com'
  cset :nginx_path_prefix, "/opt/nginx"
  cset :nginx_log_path, "#{nginx_path_prefix}/logs"
  cset :nginx_pid_path, "#{nginx_path_prefix}/var/run"
  cset :nginx_public_root_path, "#{deploy_to}/current/public"
  cset :nginx_redirects, {}
  cset :nginx_rewrites, ''
  cset :nginx_health_check, true
  cset :nginx_ssl, false
  cset :nginx_max_body_size, '1m'
    
  cset :nginx_local_config, "#{templates_path}/nginx/nginx.conf.erb"
  cset :nginx_remote_config, "#{nginx_path_prefix}/conf/nginx.conf"
  cset :nginx_local_gzip_config, "#{templates_path}/nginx/gzip.conf.erb"
  cset :nginx_remote_gzip_config, "#{nginx_path_prefix}/conf/gzip.conf"
  cset :nginx_local_ssl_config, "#{templates_path}/nginx/ssl.conf.erb"
  cset :nginx_remote_ssl_config, "#{nginx_path_prefix}/conf/ssl.conf"
  cset :nginx_local_passenger_config, "#{templates_path}/nginx/passenger.conf.erb"
  cset :nginx_remote_passenger_config, "#{nginx_path_prefix}/conf/passenger.conf"  
  cset :nginx_local_site_config, "#{templates_path}/nginx/sites-enabled.erb"
  cset :nginx_remote_site_config, "#{nginx_path_prefix}/conf/sites-enabled/#{application}"
  cset :nginx_remote_site_available_config, "#{nginx_path_prefix}/conf/sites-available/#{application}"
  cset :nginx_sites_enabled, "#{nginx_path_prefix}/conf/sites-enabled"
  cset :nginx_sites_available, "#{nginx_path_prefix}/conf/sites-available"  

  namespace :nginx do
    task :start, :roles => :app do
      run "sudo start nginx"
    end
    
    task :stop, :roles => :app do 
      run "sudo stop nginx"
    end
    
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "sudo restart nginx"
    end

    task :setup, :roles => :app , :except => { :no_release => true } do
      run "sudo mkdir -p #{nginx_sites_enabled}"
      run "sudo mkdir -p #{nginx_sites_available}"
      run "sudo rm -f #{nginx_remote_site_available_config}"
      run "sudo rm -f #{nginx_remote_site_config}"
      
      generate_file nginx_local_config, nginx_remote_config
      generate_file nginx_local_gzip_config, nginx_remote_gzip_config
      generate_file nginx_local_ssl_config, nginx_remote_ssl_config if nginx_ssl == true
      generate_file nginx_local_passenger_config, nginx_remote_passenger_config
      generate_file nginx_local_site_config, nginx_remote_site_available_config
      
      run "sudo ln -sf #{nginx_remote_site_available_config} #{nginx_remote_site_config}"
      
      run "sudo chown #{user}:root #{nginx_log_path}"
      run "sudo mkdir -p #{nginx_pid_path}"
      run "sudo chown #{user}:root #{nginx_pid_path}"
    end
  end
end