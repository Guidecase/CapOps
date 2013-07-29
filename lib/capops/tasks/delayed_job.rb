Capistrano::Configuration.instance(:must_exist).load do 
  def args
    fetch(:delayed_job_args, "")
  end

  namespace :delayed_job do
    desc "Start the delayed_job process"
    task :start, :roles => :app do
      run "sudo start delayed_job"
    end

    desc "Stop the delayed_job process"
    task :stop, :roles => :app do 
      run "sudo stop delayed_job"
    end    

    desc "Restart the delayed_job process"
    task :restart, :roles => :app do 
      run "sudo restart delayed_job"
    end    

    desc "Check the delayed_job process status"
    task :status, :roles => :app do
      run "status delayed_job"
    end   

    desc "Show most recent delayed_job log file"
    task :log, :roles => :app do
      run "tail -300 #{current_path}/log/delayed_job.log"
    end     

    task :setup, :roles => :app do
      run "touch #{shared_path}/log/delayed_job.log"
    end

    task :symlink, :roles => :app, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/log/delayed_job.log #{latest_release}/log/delayed_job.log"
    end    
  end

  after  "deploy:stop",    "delayed_job:stop"
  after  "deploy:start",   "delayed_job:start"
  before "deploy:restart", "delayed_job:stop"
  after  "deploy:restart", "delayed_job:start"
  after  "delayed_job:setup", "delayed_job:symlink"
  after  "deploy:finalize_update", "delayed_job:symlink"  
end