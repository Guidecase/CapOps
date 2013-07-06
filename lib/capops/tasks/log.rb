Capistrano::Configuration.instance(:must_exist).load do 
  namespace :log do 
    task :setup, :roles => :app do
      log_config = <<-LOG
#{shared_path}/log/*.log {
  weekly
  missingok
  rotate 12
  compress
  delaycompress
  notifempty
  create 666 ubuntu adm
  sharedscripts
  endscript
}
      LOG

      put log_config, "/tmp/#{application}"
      run "sudo mv /tmp/#{application} /etc/logrotate.d/#{application}"
    end
    
    desc "Tail nginx log file"
    task :nginx, :roles => :app do
      run "#{try_sudo} tail -100 /opt/nginx/logs/access.log"
      run "#{try_sudo} tail -100 /opt/nginx/logs/error.log"
    end       

    namespace :tail do
    desc "Tail nginx log file stream"
      task :nginx, :roles => :app do
        run "tail -f /opt/nginx/logs/*.log" do |channel, stream, data|
          puts "#{channel[:host]}: #{data}"
          break if stream == :err
        end
      end 
    end
  end
end