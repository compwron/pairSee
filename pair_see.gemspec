# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pair_see/version'

Gem::Specification.new do |gem|
  gem.name = 'pair_see'
  gem.version = PairSee::VERSION
  gem.authors = ['compwron']
  gem.email = ['compiledwrong@gmail.com']

  gem.summary = 'See metrics about pair programming from the commandline'
  gem.description = 'See commits not by known pair, most recent commits by pairs, recommended pairings, card duration and pairing data, and cards each person has worked on'
  gem.homepage = 'https://github.com/compwron/pairsee'
  gem.license = 'MIT'

  gem.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir = 'bin'
  gem.executables = ['pairsee']
  gem.require_paths = ['lib']

  gem.add_dependency 'yamler', '~> 0.1'
  gem.add_dependency 'trollop', '~> 2.1'
  gem.add_dependency 'git', '~> 1.3'

  gem.add_development_dependency 'bundler', '~> 1.15'
  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'rspec', '~> 3.6'
  gem.add_development_dependency 'rubocop', '~> 0.49.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake_commit', '~> 1.3'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.8'
end
