task :default => :rspec

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end