require_relative "../pairSee.rb"

describe PairSee do

  subject { PairSee.new "spec/spec_config.yml"}

    before do
      `mkdir fake_git; git init fake_git; git submodule add ./fake_git/ ; cd fake_git ; echo foo > foo.txt ; git add . ;
          git commit -m "Person1/Person2 made foo" ; echo bar > bar.txt ; git add . ;
          git commit -m "Person1/Person3 made bar"`
    end

    after do
      `rm -rf fake_git`
    end

    it "should see how many commits each pair has made together" do
      subject.commits_for_pair("Person1", "Person2").should == 1
    end

    it "should get all commits which only have person1's name on them" do
      subject.commits_by_only("Person1").count.should == 2
    end

    it "should map pair to # of commits by pair, sorted by count" do
      subject.pair_commits_list.should == ["Person2, Person3: 0", "Person1, Person3: 1", "Person1, Person2: 1"]
    end
  end
