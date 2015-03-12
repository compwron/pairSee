# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pair_see/version'

Gem::Specification.new do |spec|
  spec.name          = 'pair_see'
  spec.version       = PairSee::VERSION
  spec.authors       = ['compwron']
  spec.email         = ['compiledwrong@gmail.com']

  spec.summary       = 'See metrics about pair programming from the commandline'
  spec.homepage      = 'https://github.com/compwron/pairsee'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'yamler'
  spec.add_dependency 'trollop'
  spec.add_dependency 'git'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rake_commit'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
