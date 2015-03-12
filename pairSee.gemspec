# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pairSee/version'

Gem::Specification.new do |spec|
  spec.name          = "pairSee"
  spec.version       = PairSee::VERSION
  spec.authors       = ["compwron"]
  spec.email         = ["compiledwrong@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]


  spec.add_dependency 'yamler'
  spec.add_dependency 'trollop'
  spec.add_dependency 'git'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rake_commit'
  spec.add_development_dependency 'codeclimate-test-reporter'
end

# require 'rspec/core/rake_task'
# RSpec::Core::RakeTask.new(:rspec) do |spec|
#   spec.pattern = 'spec/*_spec.rb'
#   spec.rspec_opts = ['--backtrace']
# end

# desc 'do simple rubocop fixes'
# task :rubocop do
#   puts 'running rubocop'
#   `rubocop -a`
# end