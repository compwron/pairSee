require_relative "spec_helper"

describe SvnLogLines do
  let(:log_location) { 'spec/fixtures/one_commit.txt' }
  let(:after_date) { '0-1-1' }
  let(:config) { 'spec/fixtures/config.yml' }
  let(:log_lines) { SvnLogLines.new(log_location, after_date, config) }

  describe "lines" do
    let(:log_location) { 'spec/fixtures/one_commit.txt' }

    it "make one line from a file containing one line" do
      log_lines.size.should == 1
    end

    it "should see that line is authored by a line author" do
      log_lines.first.authored_by?([], "Alice").should be_true
    end
  end

  describe "lines without authors" do
    let(:log_location) { 'spec/fixtures/one_commit_without_author.txt' }

    it "should see that, in absence of line author, line is authored by the name mapped to commitID1" do
      log_lines.first.authored_by?(log_lines.committer_mappings(config), "Alice").should be_true
    end

    it "should see that, in absence of line author, line is not authored by devs other than those with name mapped to commitID1" do
      log_lines.first.authored_by?(log_lines.committer_mappings(config), "Bob").should be_false
    end
  end

  describe "#committer_mappings" do
    it "should see committers in config file" do
      log_lines.committer_mappings(config).should == {"Alice" => "committerID1", "Bob" => "committerID2"}
    end
  end

  describe "#active?" do
    it "should know that a dev is active because dev's name is on a log line" do
      log_lines.active?("Alice")
    end
  end

  describe "#commits_for_pair" do
    it "should see that a commit is by a pair" do
      log_lines.commits_for_pair("Alice", "Bob").size.should == 1
    end

    it "should see that a commit is not by a pair" do
      log_lines.commits_for_pair("Alice", "James").size.should == 0
    end
  end

  describe "#solo_commits no" do
    it "should see that a commit is not solo" do
      log_lines.solo_commits(["Alice", "Bob"], "Alice").size.should == 0
    end
  end

  describe "#solo_commits yes" do
    let(:log_location) { 'spec/fixtures/one_commit_without_author.txt' }

    it "should see that a commit is solo when committer ID is present without name" do
      log_lines.solo_commits(["Alice", "Bob"], "Alice").size.should == 1
      log_lines.solo_commits(["Alice", "Bob"], "Alice").first.authored_by?("Alice").should be_true
    end
  end

end
