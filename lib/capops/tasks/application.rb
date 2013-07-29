Capistrano::Configuration.instance(:must_exist).load do 
  # Server settings
  cset :user, 'ubuntu'
  cset :group, 'www-data'
  cset :admin_runner, 'ubuntu'
  cset :use_sudo, false
  cset :web_server, :nginx
  cset :database, :mongoid

  # SCM settings
  set :scm, :git
  set :branch, 'master'
  set :scm_verbose, true
  set :git_enable_submodules, 0
  set :keep_releases, 2
  set :deploy_via, :remote_cache
  set :deploy_to, "/opt/#{application}"

  # Git  settings
  default_run_options[:pty] = true
  ssh_options[:forward_agent] = true
end