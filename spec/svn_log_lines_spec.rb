require_relative "spec_helper"

describe SvnLogLines do
  let(:log_location) {'spec/fixtures/svn_log.txt'}
  let(:after_date) { '0-1-1' }
  let(:log_lines) { SvnLogLines.new(log_location, after_date).lines }

  describe "lines" do
    let(:log_location) { 'spec/fixtures/one_commit.txt' }
    it "make one line from a file containing one line" do
      log_lines.size.should == 1
    end
  end

end
