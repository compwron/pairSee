# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pair_see/version'

Gem::Specification.new do |spec|
  spec.name = 'pair_see'
  spec.version = PairSee::VERSION
  spec.authors = ['compwron']
  spec.email = ['compiledwrong@gmail.com']

  spec.summary = 'See metrics about pair programming from the commandline'
  spec.description = 'See commits not by known pair, most recent commits by pairs, recommended pairings, card duration and pairing data, and cards each person has worked on'
  spec.homepage = 'https://github.com/compwron/pairsee'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'yamler', '~> 0.1'
  spec.add_dependency 'trollop', '~> 2.0'
  spec.add_dependency 'git', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rubocop', '~> 0.29'
  spec.add_development_dependency 'rake_commit', '~> 1.1'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.7'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'pry'
end
