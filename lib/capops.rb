require 'capistrano'
require 'capistrano/cli'
require 'aws'

if Capistrano::Configuration.instance
  require 'capistrano/ext/multistage'

  require_relative 'capops/helpers'

  require 'bundler/setup' if defined? Bundler
  require 'bundler/capistrano' if defined? Bundler
  require "whenever/capistrano/recipes" if defined? Whenever

  recipes = Dir.glob(File.join(File.dirname(__FILE__), '/capops/tasks/**/*.rb'))
  recipes.sort.each do |f| 
    load f
  end
end