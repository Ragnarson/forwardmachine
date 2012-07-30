# -*- encoding: utf-8 -*-
require File.expand_path('../lib/forwardmachine/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mariusz Pietrzyk"]
  gem.email         = ["wijet@wijet.pl"]
  gem.description   = %q{
    Simple forwarding service written in Ruby with EventMachine.
    Allows to set up port forwarding to given destination in runtime.
  }
  gem.summary       = %q{Port forwarding service configurable in runtime}
  gem.homepage      = "https://github.com/ragnarson/forwardmachine"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "forwardmachine"
  gem.require_paths = ["lib"]
  gem.version       = ForwardMachine::VERSION
  
  gem.add_runtime_dependency "eventmachine"
  gem.add_runtime_dependency "em-logger"
  
  gem.add_development_dependency "rspec"
end
