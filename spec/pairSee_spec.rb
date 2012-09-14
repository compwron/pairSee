
require_relative "../lib/pair_see"

describe PairSee do

  subject { PairSee.new "fake_git", "spec/spec_config.yml", "0-1-1" }

    before do
      `mkdir fake_git; git init fake_git; cd fake_git ; 
          echo foo >> foo.txt ; git add . ; git commit -m "Person1/Person2 made foo" ; 
          echo bar >> foo.txt ; git add . ; git commit -m "Person1 Person3 made bar" ; 
          echo baz >> foo.txt ; git add . ; git commit -m "Person3 made baz" ; 
          echo cat >> foo.txt ; git add . ; git commit -m "Person1,Person3 made cat" 
          echo dog >> foo.txt ; git add . ; git commit -m "PErson4|person5 thing a thing thing"  # testing capitalization typos
          echo dog >> foo.txt ; git add . ; git commit -m "nameless commit" 
          echo dog >> hai.txt ; git add . ; git commit -m "Merge remote-tracking branch 'origin/master'" 
          echo dog >> hai.txt ; git add . ; git commit -m "Person5: Merge thing and foo"
          echo dog >> foo.txt ; git add . ; git commit -m "Person4 Person6 just a commit by this pair"
          echo dog >> foo.txt ; git add . ; git commit -m "Person4 Person7 most recent commit by this pair" 
          echo dog >> foo.txt ; git add . ; git commit -m "Person4 Person6 most recent commit by this pair"
          echo dog >> foo.txt ; git add . ; git commit -m "ActiveDev wrote some code" `

      @current_date_string = "#{Time.now.year}-#{Time.now.strftime("%m")}-#{Time.now.strftime("%d")}"
      @never = Time.parse("1970-1-1")    
    end

    after do
      `rm -rf fake_git`
    end

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

    it "prints a list of commits it did not connect with a name" do
      extras = subject.commits_not_by_known_pair.map(&:to_s)
      extras[0].should include "nameless" #hack to avoid regex right now
      extras.should_not include "Person1, Person3: made cat"
      extras.should_not include "Person1, Person3: 2"
    end

    it "does not include merge commits in the list of commits without dev names" do
      subject.commits_not_by_known_pair.should_not include "Merge"
    end

    it "does not wrongfully exclude commits with 'merge' in the message from the count" do
      subject.all_commits.should include "Person5: 1"
    end

    it "gets accurate dates for commit" do
      commit_line = "2012-09-07 14:12:33 -0500 Person1|Person2 made foo inherit from bar"
      subject.commit_date(commit_line).should == Time.new(2012,9,7)
    end

    it "sees most recent commit by a pair" do
      subject.most_recent_commit_date("Person4", "Person5").should == Time.parse(@current_date_string)
      subject.most_recent_commit_date("Person4", "Person1").should == @never
    end

    it "gets most recent dates of all pair commits" do
      subject.all_most_recent_commits.should include "Person1, Person3: #{@current_date_string}"
      subject.all_most_recent_commits.should include "Person1, Person6: not yet"
    end

    it "gets most recent dates of all pair commits, sorted temporally" do
      subject.all_most_recent_commits.first.should include "Person1, Person2: #{@current_date_string}"
      subject.all_most_recent_commits.last.should include "not yet"
    end

    it "should recommend pairs based on least recent active dev pair" do
      subject.recommended_pairings.should include "Person1, ActiveDev"
      subject.recommended_pairings.should_not include "Person1, Person2"
    end

    it "should identify active devs, i.e. has committed in the last two weeks" do
      active_devs = subject.active_devs("spec/spec_config.yml")
      active_devs.should include "ActiveDev"
      active_devs.should include "Person1" 
      active_devs.should_not include "InactiveDev"
    end

    it "knows whether dev is active" do
      subject.is_active("ActiveDev").should == true
      subject.is_active("InactiveDev").should == false
    end

  end
