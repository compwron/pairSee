require_relative "spec_helper"

describe PairSee do
  let(:current_date) { Date.today }
  let(:never) { Date.parse("1970-1-1") }
  let(:repo) { 'fake_git' }
  let(:config) { 'spec/spec_config.yml' }
  let(:after_date) { '0-1-1' }

  subject { PairSee.new repo, config, after_date }

  def create_commit message
    `cd #{repo} && echo bar >> foo.txt && git add . && git commit -m "#{message}"`
  end

  before :each do
    `mkdir #{repo} && git init #{repo}`
  end

  after :each do
    `rm -rf #{repo}`
  end

  describe "#all_commits" do
    let(:all_commits) { subject.all_commits }

    it "contains counts for all pairs which have committed" do
      create_commit("Person1/Person3 code")
      create_commit("Person1/Person3 more code")
      create_commit("Person1/Person2 code")
      all_commits.should include "Person1, Person3: 2"
      all_commits.should include "Person1, Person2: 1"
    end

    it "doesn't list counts for pairs who have no commits" do
      all_commits.should_not include "Person2, Person3: 0"
    end

    it "gets all commits which only have person1's name on them" do
      create_commit("Person3 code")
      all_commits.should_not include "Person1: 0"
      all_commits.should include "Person3: 1"
    end

    it "sorts all by count" do
      create_commit("Person1/Person3 code")
      create_commit("Person1/Person3 more code")
      create_commit("Person1/Person2 code") 
      all_commits.last.should end_with ": 2"
      all_commits.first.should end_with ": 1"
    end

    context "with an after date in the future" do
      let(:after_date) { '2013-01-01' }

      it "can see all commits since a passed-in date" do
        all_commits.should have(0).commits
      end
    end

    it "sees names with capitalization typos" do
      create_commit("PErson4|person5 thing a thing thing")
      all_commits.should include "Person4, Person5: 1"
    end

    it "does not wrongfully exclude commits with 'merge' in the message from the count" do
      create_commit("Person5: Merge thing and foo")
      all_commits.should include "Person5: 1"
    end
  end

  describe "#commits_not_by_known_pair" do
    it "prints a list of commits it did not connect with a name" do
      create_commit("nameless")
      create_commit("Person1, Person3: code")
      extras = subject.commits_not_by_known_pair.map(&:to_s)
      extras[0].should include "nameless" 
      extras.should_not include "Person1, Person3: made cat"
    end

    it "does not include merge commits in the list of commits without dev names" do
      create_commit("Merge remote-tracking branch 'origin/master'")
      subject.commits_not_by_known_pair.should_not include "Merge"
    end
  end

  describe "#most_recent_commit_date" do
    it "sees most recent commit by a pair" do
      create_commit("Person4|Person5 code")
      subject.most_recent_commit_date("Person4", "Person5").should == current_date
      subject.most_recent_commit_date("Person4", "Person1").should be_nil
    end
  end

  describe "#all_most_recent_commits" do
    it "gets most recent dates of all pair commits" do
      create_commit("Person1|Person3 code")
      create_commit("Person6")
      subject.all_most_recent_commits.should include "Person1, Person3: #{current_date.to_s}"
      subject.all_most_recent_commits.should include "Person1, Person6: not yet"
    end

    it "gets most recent dates of all pair commits, sorted temporally" do
      create_commit("Person1|Person2 code")
      create_commit("Person3")
      subject.all_most_recent_commits.first.should include "Person1, Person2: #{current_date.to_s}"
      subject.all_most_recent_commits.last.should include "not yet"
    end
  end

  describe "#unpaired_in_range" do
    it "recommends pairs based on least recent active dev pair" do
      create_commit("Person1|Person2 code")
      create_commit("ActiveDev code")
      subject.unpaired_in_range.should include "Person1, ActiveDev"
      subject.unpaired_in_range.should_not include "Person1, Person2"
    end
  end

  describe "#active_devs" do
    it "identifies active devs" do
      create_commit("Person1")
      create_commit("ActiveDev")
      active_devs = subject.active_devs(config)
      
      active_devs.should include "ActiveDev"
      active_devs.should include "Person1"
      active_devs.should_not include "InactiveDev"
    end
  end

  describe "#is_active" do
    it "is true when the dev is active" do
      create_commit("ActiveDev")
      subject.is_active("ActiveDev").should be_true
      subject.is_active("InactiveDev").should be_false
    end
  end

  describe "#least_recent_pair" do
    it "sees least recent pairing" do
      create_commit("Person1, Person2")
      create_commit("ActiveDev")
      subject.least_recent_pair.should include "Person1, Person2"
      subject.least_recent_pair.should_not include "ActiveDev"
    end
  end
end
