Capistrano::Configuration.instance(:must_exist).load do
  namespace :passenger do
    desc "Restart Rails app running under Phusion Passenger by touching restart.txt"
    task :restart, :roles => :app do
      run "#{sudo} touch #{current_path}/tmp/restart.txt"
    end

    desc "Inspect Phusion Passenger's memory usage."
    task :memory, :roles => :app do
      run "sudo passenger-memory-stats"
    end
        
    desc "Inspect Phusion Passenger's internal status."
    task :status, :roles => :app do
      run "sudo passenger-status"
    end
        
    task :version, :roles => :app do
      run "passenger -v"
    end

    desc "Show Passenger's root path."
    task :config, :roles => :app do
      run "passenger-config --root"
    end    

    task :setup, :roles => :app do
      run "sudo gem install passenger --no-ri --no-rdoc"
      run "sudo passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx --extra-configure-flags=\"--with-http_gzip_static_module --with-http_ssl_module --with-ipv6\""
    end

    task :upgrade, :roles => :app do
      run "sudo stop nginx"
      passenger.setup
      run "sudo start nginx"
    end
  end
end