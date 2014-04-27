# encoding: utf-8

$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'ingraphrb/version'

Gem::Specification.new do |gem|
  gem.name        = 'ingraphrb'
  gem.version     = IngraphRB::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = 'Simplifi Development Team'
  gem.email       = 'dev@simpli.fi'
  gem.homepage    = 'http://github.com/simplifi/ingraphrb'
  gem.summary     = %q{Ingraph Ruby gem}
  gem.description = %q{Ruby gem for accessing Ingraph (Icinga) performance data}

  gem.add_dependency 'sequel'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.rdoc_options     = ['--charset=UTF-8']
  gem.require_paths = ['lib']
end
