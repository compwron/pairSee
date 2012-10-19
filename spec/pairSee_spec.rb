require_relative "../lib/pair_see"

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

  before do
    `mkdir #{repo} && git init #{repo}`

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
    `rm -rf #{repo}`
  end

  describe "see cards worked on" do
    card_prefix = "FOO"

    it "sees that a card has been worked" do
      create_commit("[FOO-1]")
      subject.cards_worked(card_prefix).should == 1
    end

    it "does not imagine that a card has not been worked when it has not been" do
      create_commit("whatever")
      subject.cards_worked(card_prefix).should == 0
    end

    it "sees multiple cards worked" do
      create_commit("[FOO-1] stuff")
      create_commit("[FOO-1] more stuff")
      subject.cards_worked(card_prefix).should == 2
    end

    it "sees which cards have been worked" do
      create_commit("[FOO-1]")
      subject.card_numbers(card_prefix).should == ["FOO-1"]
    end

    it "sees multiple card numbers  worked" do
      create_commit("[FOO-1]")
      create_commit("[FOO-2]")
      subject.card_numbers(card_prefix).should include "FOO-1"
      subject.card_numbers(card_prefix).should include "FOO-2"
      subject.card_numbers(card_prefix).size.should == 2
    end

    it "given card name, sees number of commits on a card" do
      create_commit("[FOO-1]")
      card_name = "FOO-1"
      subject.commits_on_card(card_name).should == 1
    end

    it "sees multiple commits on a card" do
      create_commit("[FOO-1] code")
      create_commit("[FOO-1] more code")
      create_commit("[FOO-2] code for other card")
      card_name = "FOO-1"
      subject.commits_on_card(card_name).should == 2
    end

    it "outputs card worked data in format FOO-1 date1 date2 length-in-days" do
    end
  end

  describe "#all_commits" do
    let(:all_commits) { subject.all_commits }

    it "contains counts for all pairs which have committed" do
      all_commits.should include "Person1, Person3: 2"
      all_commits.should include "Person1, Person2: 1"
#      all_commits.should have_pair("person1", "Person2").with_count(2)
    end

    it "doesn't list counts for pairs who have no commits" do
      all_commits.should_not include "Person2, Person3: 0"
    end

    it "gets all commits which only have person1's name on them" do
      all_commits.should_not include "Person1: 0"
      all_commits.should include "Person3: 1"
    end

    it "sorts all by count" do
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
      all_commits.should include "Person4, Person5: 1"
    end

    it "does not wrongfully exclude commits with 'merge' in the message from the count" do
      all_commits.should include "Person5: 1"
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
      subject.most_recent_commit_date("Person4", "Person5").should == current_date
      subject.most_recent_commit_date("Person4", "Person1").should be_nil
    end
  end

  describe "#all_most_recent_commits" do
    it "gets most recent dates of all pair commits" do
      subject.all_most_recent_commits.should include "Person1, Person3: #{current_date.to_s}"
      subject.all_most_recent_commits.should include "Person1, Person6: not yet"
    end

    it "gets most recent dates of all pair commits, sorted temporally" do
      subject.all_most_recent_commits.first.should include "Person1, Person2: #{current_date.to_s}"
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
      active_devs = subject.active_devs(config)
      active_devs.should include "ActiveDev"
      active_devs.should include "Person1" 
      active_devs.should_not include "InactiveDev"
    end
  end

  describe "#is_active" do
    it "is true when the dev is active" do
      subject.is_active("ActiveDev").should be_true
      subject.is_active("InactiveDev").should be_false
    end
  end

  describe "#least_recent_pair" do
    it "sees least recent pairing" do
      subject.least_recent_pair.should include "Person1, Person2"
      subject.least_recent_pair.should_not include "ActiveDev"
    end
  end

  
end











