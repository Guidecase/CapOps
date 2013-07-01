Capistrano::Configuration.instance(:must_exist).load do 
  namespace :cron do
    cset :cron_log_path, "#{shared_path}/log/cron.log"
    cset :whenever_command, "bundle exec whenever"
    cset :whenever_environment, stage if exists?(:stage)

    desc "Update the local crontab file with whenever schedule"  
    task :update, :roles => :app, :except => { :no_release => true } do  
      tab = fetch :application
      set :whenever, fetch(:current_release)
      whenever_run_commands :path => current_release, 
                            :flags => "--update-crontab #{tab} --set environment=#{environment}"
    end     

    desc "List crontab"
    task :list, :roles => :app, :except => { :no_release => true } do
      run "crontab -l"
    end  
    
    desc "Show cron status"
    task :status, :roles => :app, :except => { :no_release => true } do
      run "sudo status cron"
    end   
  end
end