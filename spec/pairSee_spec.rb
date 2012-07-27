
require_relative "../lib/pair_see"

describe PairSee do

  subject { PairSee.new "fake_git", "spec/spec_config.yml", "0-1-1" }

    before do
      `mkdir fake_git; git init fake_git; cd fake_git ; 
          echo foo > foo.txt ; git add . ; git commit -m "Person1/Person2 made foo" ; 
          echo bar > bar.txt ; git add . ; git commit -m "Person1 Person3 made bar" ; 
          echo baz > baz.txt ; git add . ; git commit -m "Person3 made baz" ; 
          echo cat > cat.txt ; git add . ; git commit -m "Person1,Person3 made cat" 
          echo dog > dog.txt ; git add . ; git commit -m "PErson4|person5 thing a thing thing"  # testing capitalization typos
          echo dog > hai.txt ; git add . ; git commit -m "commit message without names in it" `
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
      subject.commits_not_by_known_pair.should include "commit message without names in it"
      subject.commits_not_by_known_pair.should_not include "Person1,Person3 made cat"
      subject.commits_not_by_known_pair.should_not include "Person1, Person3: 2"

    end

  end
