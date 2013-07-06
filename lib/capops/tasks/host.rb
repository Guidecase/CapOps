Capistrano::Configuration.instance(:must_exist).load do 
  namespace :host do
    desc "Lists open system ports"
    task :ports, :roles => :app do
      run "netstat -lp"
      run "netstat -anltp | grep 'LISTEN'"
    end
  end
end