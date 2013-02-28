# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pivo_flow/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Adam Nowak"]
  gem.email         = ["lubieniebieski@gmail.com"]
  gem.description   = %q{Automated querying for pivotal stories, adding story id to commit message, etc.}
  gem.summary       = %q{Simple pivotal tracker integration for day to day work with git}
  gem.homepage      = "https://github.com/lubieniebieski/pivo_flow"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pivo_flow"
  gem.require_paths = ["lib"]
  gem.version       = PivoFlow::VERSION

  gem.add_runtime_dependency "pivotal-tracker"
  gem.add_runtime_dependency "grit"
  gem.add_runtime_dependency "highline"
  gem.add_runtime_dependency "colorize"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "fakeweb"

end
