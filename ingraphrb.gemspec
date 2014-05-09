# encoding: utf-8

$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'ruby_ingraph_client/version'

Gem::Specification.new do |gem|
  gem.name        = 'ruby_ingraph_client'
  gem.version     = RubyIngraphClient::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = 'Simplifi Development Team'
  gem.email       = 'dev@simpli.fi'
  gem.homepage    = 'http://github.com/simplifi/ruby_ingraph_client'
  gem.summary     = %q{Ingraph Ruby gem}
  gem.description = %q{Ruby gem for accessing Ingraph (Icinga) performance data}

  gem.add_dependency 'pg'
  gem.add_dependency 'sequel'
  gem.add_dependency 'timespan'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'simplecov'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.rdoc_options     = ['--charset=UTF-8']
  gem.require_paths = ['lib']
end
