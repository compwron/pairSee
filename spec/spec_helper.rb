require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

`git config --global user.email "pairsee@example.com"`
`git config --global user.name "pairsee"`

require_relative '../lib/pair_see'
require_relative '../lib/combo'
require_relative '../lib/date_combo'
require_relative '../lib/log_lines'
require_relative '../lib/log_line'
require_relative '../lib/card'
