# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capops/version'

Gem::Specification.new do |spec|
  spec.name          = "capops"
  spec.version       = CapOps::VERSION
  spec.summary       = "Capistrano operations"
  spec.description   = "This gem provides capistrano scripts for sundry developer operations tasks"
  spec.authors       = ['Earlydoc', 'Travis Dunn']
  spec.email         = 'developer@earlydoc.com'
  spec.homepage      = 'https://www.earlydoc.com'
  spec.license       = "Private"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "rake"

  spec.add_dependency "bundler", "~> 1.3"
  spec.add_dependency "capistrano", "2.15.4"
  spec.add_dependency "capistrano-ext", ">= 1.2.x"
  spec.add_dependency "aws-sdk", ">= 1.9.x"
end