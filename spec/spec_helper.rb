require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

`git config --local user.email "compiledwrong+github@gmail.com"`
`git config --local user.name "compiledwrong"`

require_relative '../lib/pair_see'
require_relative '../lib/combo'
require_relative '../lib/date_combo'
require_relative '../lib/log_lines'
require_relative '../lib/log_line'
require_relative '../lib/card'
