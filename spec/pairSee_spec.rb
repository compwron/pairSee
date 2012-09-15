require_relative "../lib/pair_see"

describe PairSee do
  let(:current_date_string) { "#{Time.now.year}-#{Time.now.strftime("%m")}-#{Time.now.strftime("%d")}" }
  let(:never) { Time.parse("1970-1-1") }
  subject { PairSee.new "fake_git", "spec/spec_config.yml", "0-1-1" }

  def create_commit message
     `cd fake_git && echo bar >> foo.txt && git add . && git commit -m "#{message}"`
  end

  before do
    `mkdir fake_git; git init fake_git;`

    create_commit("Person1/Person2 made foo")
    create_commit("Person1 Person3 made bar")
    create_commit("Person3 made baz")
    create_commit("Person1,Person3 made cat")
    create_commit("PErson4|person5 thing a thing thing")  # testing capitalization typos
    create_commit("nameless commit")
    create_commit("Merge remote-tracking branch 'origin/master'")
    create_commit("Person5: Merge thing and foo")
    create_commit("Person4 Person6 just a commit by this pair")
    create_commit("Person4 Person7 most recent commit by this pair")
    create_commit("Person4 Person6 most recent commit by this pair")
    create_commit("ActiveDev wrote some code")   
  end

  after do
    `rm -rf fake_git`
  end

  describe "#all_commits" do
    it "contains counts for all pairs which have committed" do
      subject.all_commits.should include "Person1, Person3: 2"
      subject.all_commits.should include "Person1, Person2: 1"
    end

    it "doesn't list counts for pairs who have no commits" do
      subject.all_commits.should_not include "Person2, Person3: 0"
    end

    it "gets all commits which only have person1's name on them" do
      subject.all_commits.should_not include "Person1: 0"
      subject.all_commits.should include "Person3: 1"
    end

    it "sorts all by count" do
      subject.all_commits.last.should include ": 2"
      subject.all_commits.first.should include ": 1"
    end

    it "can see all commits since a passed-in date" do
      all_commits_made_next_year = PairSee.new("fake_git", "spec/spec_config.yml", "2013-01-01")
      all_commits_made_next_year.all_commits.size.should == 0
    end

    it "sees names with capitalization typos" do
      subject.all_commits.should include "Person4, Person5: 1"
    end

    it "does not wrongfully exclude commits with 'merge' in the message from the count" do
      subject.all_commits.should include "Person5: 1"
    end
  end

  describe "#commits_not_by_known_pair" do
    it "prints a list of commits it did not connect with a name" do
      extras = subject.commits_not_by_known_pair.map(&:to_s)
      extras[0].should include "nameless" #hack to avoid regex right now
      extras.should_not include "Person1, Person3: made cat"
      extras.should_not include "Person1, Person3: 2"
    end

    it "does not include merge commits in the list of commits without dev names" do
      subject.commits_not_by_known_pair.should_not include "Merge"
    end
  end

  describe "#most_recent_commit_date" do
    it "sees most recent commit by a pair" do
      subject.most_recent_commit_date("Person4", "Person5").should == Time.parse(current_date_string)
      subject.most_recent_commit_date("Person4", "Person1").should == never
    end
  end

  describe "#all_most_recent_commits" do
    it "gets most recent dates of all pair commits" do
      subject.all_most_recent_commits.should include "Person1, Person3: #{current_date_string}"
      subject.all_most_recent_commits.should include "Person1, Person6: not yet"
    end

    it "gets most recent dates of all pair commits, sorted temporally" do
      subject.all_most_recent_commits.first.should include "Person1, Person2: #{current_date_string}"
      subject.all_most_recent_commits.last.should include "not yet"
    end
  end

  describe "#unpaired_in_range" do
    it "recommends pairs based on least recent active dev pair" do
      subject.unpaired_in_range.should include "Person1, ActiveDev"
      subject.unpaired_in_range.should_not include "Person1, Person2"
    end
  end

  describe "#active_devs" do
    it "identifies active devs" do
      active_devs = subject.active_devs("spec/spec_config.yml")
      active_devs.should include "ActiveDev"
      active_devs.should include "Person1" 
      active_devs.should_not include "InactiveDev"
    end
  end

  describe "#is_active" do
    it "is true when the dev is active" do
      subject.is_active("ActiveDev").should == true
      subject.is_active("InactiveDev").should == false
    end
  end

  describe "#least_recent_pair" do
    it "sees least recent pairing" do
      subject.least_recent_pair.should include "Person1, Person2"
      subject.least_recent_pair.should_not include "ActiveDev"
    end
  end
end
