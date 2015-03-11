# require 'bundler/gem_tasks'

task default: [] do
  Rake::Task[:rubocop].invoke
  Rake::Task[:rspec].invoke
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

desc 'do simple rubocop fixes'
task :rubocop do
  out = `rubocop -a`
  p out
end
