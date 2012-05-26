# -*- encoding: utf-8 -*-
require File.expand_path('../lib/em-xs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Julien Ammous"]
  gem.email         = ["schmurfy@gmail.com"]
  gem.description   = %q{EventMachine wrapper for crossroads}
  gem.summary       = %q{EventMachine wrapper for crossroads}
  gem.homepage      = "https://github.com/schmurfy/em-xs"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "em-xs"
  gem.require_paths = ["lib"]
  gem.version       = EM::XS::VERSION
  
  gem.add_dependency 'ffi-rxs'
  gem.add_dependency 'eventmachine', '~> 1.0.0.beta4'
end
