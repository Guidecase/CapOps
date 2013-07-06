def cset(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def environment  
  if exists?(:stage)
    stage == 'reserve' ? 'production' : stage
  elsif exists?(:rails_env)
    rails_env  
  elsif ENV['RAILS_ENV']
    ENV['RAILS_ENV']
  else
    'production'  
  end
end

def db_settings
  config = ''
  run "cat #{current_path}/config/#{database}.yml" do |ch, st, data| 
    config = data
  end   
  YAML::load(config)
end

def aws_settings
  config = ''
  run "cat #{fetch(:aws_release_config)}" do |ch, st, data| 
    config = data
  end   
  YAML::load(config)
end

# suppress output that might contain sensitive info like passwords by setting log level > DEBUG
def discreet_output(&block)
  ll = self.logger.level
  self.logger.level = Capistrano::Logger::INFO  
  yield
  self.logger.level = ll
end

def parse_config(file)
  require 'erb'
  template = File.read(file)
  return ERB.new(template).result(binding)
end

def generate_file(local_file, remote_file)
  temp_file = '/tmp/' + File.basename(local_file)
  server_temp_file = '/tmp/capops.txt'
  
  buffer = parse_config(local_file)
  File.open(temp_file, 'w+') { |f| f << buffer }
  upload temp_file, server_temp_file, :via => :scp
  
  run "sudo mv -f #{server_temp_file} #{remote_file}"
  run_locally "rm #{temp_file}"
end

def templates_path
  expanded_path_for('templates/')
end

def expanded_path_for(path)
  e = File.join(File.dirname(__FILE__),path)
  File.expand_path(e)
end

def ask(message, default=true)
  Capistrano::CLI.ui.agree(message)
end

# current_revision will throw an exception if this is the first deploy...
def safe_current_revision
  begin
    current_revision
  rescue => e
    logger.info "*" * 80
    logger.info "An exception as occured while fetching the current revision. This is to be expected if this is your first deploy to this machine. Othewise, something is broken :("
    logger.info e.inspect
    logger.info "*" * 80
    nil
  end
end

def current_git_branch
  branch = `git symbolic-ref HEAD 2> /dev/null`.strip.gsub(/^refs\/heads\//, '')
end