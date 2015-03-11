require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'git'
require 'fileutils'

Dir[File.expand_path('../../lib/*.rb', __FILE__)].each do |file|
  require file
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 3
  config.order = :random
  Kernel.srand config.seed
end
