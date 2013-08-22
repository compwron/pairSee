require_relative "spec_helper"

describe SvnLogLines do
  let(:log_location) { 'spec/fixtures/one_commit.txt' }
  let(:after_date) { '0-1-1' }
  let(:config) { 'spec/fixtures/config.yml' }
  let(:log_lines) { SvnLogLines.new(log_location, after_date, config) }

  describe "lines" do
    let(:log_location) { 'spec/fixtures/one_commit.txt' }

    it "make one line from a file containing one line" do
      log_lines.lines.size.should == 1
    end

    it "should see that line is authored by a line author" do
      log_lines.lines.first.authored_by?("Alice").should be_true
    end

    it "should see that, in absence of line author, line is authored by the name mapped to commitID1" do
      log_lines.lines.first.authored_by?("Alice").should be_true
    end
  end

  describe "lines without authors" do
    let(:log_location) { 'spec/fixtures/one_commit_without_author.txt' }

    it "should see that, in absence of line author, line is authored by the name mapped to commitID1" do
      #log_lines.lines.first.authored_by?("Alice").should be_true
    end
  end

  describe "#committer_mappings" do
    it "should see committers in config file" do
      log_lines.committer_mappings(config).should == {"committerID1" => "Alice", "committerID2" => "Bob"}
    end
  end

end
