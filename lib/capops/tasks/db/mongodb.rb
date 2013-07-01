Capistrano::Configuration.instance(:must_exist).load do 
  cset :db_local_config, "#{templates_path}/rails/#{database}.yml.erb"
  cset :db_remote_config, "#{shared_path}/config/#{database}.yml"
  cset :db_release_config, "#{current_path}/config/#{database}.yml"  

  namespace :db do
    task :setup, :roles => :app, :except => { :no_release => true } do
      cset(:db_name) { Capistrano::CLI.ui.ask "Enter #{environment} database name:" }
      cset(:db_host) { Capistrano::CLI.ui.ask "Enter #{environment} database host:" }
      cset(:db_port) { Capistrano::CLI.ui.ask "Enter #{environment} database port:" }
      cset(:db_username) { Capistrano::CLI.ui.ask "Enter #{environment} database user name:" }
      cset(:db_password) { Capistrano::CLI.password_prompt "Enter #{environment} database user password:" }

      generate_file db_local_config, db_remote_config
    end

    task :symlink, :except => { :no_release => true } do
      run "if [ -d #{current_path} ]; then ln -nfs #{db_remote_config} #{db_release_config}; fi"
    end    

    desc "Export DB collections to local & upload to S3"
    task :backup do
      # export from server connection
      config = db_settings[environment.to_s]
      db = config['database']
      un = config['username']
      pw = config['password'] 
      host = config['host']
      port = config['port']

      output_dir = '/tmp/backups/'

      discreet_output do
        backup_collections.each do |c|
          run_locally "mongoexport --host #{host} --port #{port} --username #{un} --password #{pw} --db #{db} --collection #{c} --out #{output_dir}#{c}.json"
        end
      end

      # upload to S3 backup bucket
      config = aws_settings[environment.to_s]
      AWS.config :logger => self.logger
      AWS.config config

      s3 = AWS::S3.new config
      bucket = s3.buckets['earlydoc']

      backup_collections.each do |c|
        filename = "#{output_dir}#{c}.json"
        basename = File.basename(filename)

        o = bucket.objects["backups/db/#{basename}"]
        o.write(:file => filename)

        p "Backed up #{filename} to:"
        p o.public_url.to_s
      end

      # cleanup
      run_locally "rm -rf /tmp/backups"
    end
  end    

  namespace :deploy do
    task :migrate do; end;
  end
end