require_relative "spec_helper"

describe PairSee do
  let(:current_date) { Date.today }
  let(:repo) { 'fake_git' }
  let(:config) { 'spec/spec_config.yml' }
  let(:after_date) { '0-1-1' }

  subject { PairSee.new repo, config, after_date }

  def create_commit message
    `cd #{repo} && echo bar >> foo.txt && git add . && git commit -m "#{message}"`
  end

  before do
    `mkdir #{repo} && git init #{repo}`
    create_commit("init repo before tests in order to prevent 'fatal: bad default revision 'HEAD''")
  end

  after do
    `rm -rf #{repo}`
  end

  describe "#card_data" do
    it "apparently needs to see card names without brackets" do
      create_commit("[FOO-1] one")
      create_commit("FOO-1 two")
      subject.card_data("FOO").should == [Card.new("FOO-1", 2, current_date, current_date)]
    end

    it "in order by duration" do
      create_commit("[FOO-1] one")
      create_commit("[FOO-1] two")
      create_commit("[FOO-1] three")

      create_commit("[FOO-2] one ")
      create_commit("[FOO-2] two ")

      create_commit("[FOO-3] one ")

      data = subject.card_data("FOO")

      three_commit_card = Card.new("FOO-1", 3, after_date, current_date)
      one_commit_card = Card.new("FOO-1", 1, current_date, current_date)

      data.size.should == 3
      data.first.should == three_commit_card
      data.last.should == one_commit_card
    end

    it "gets data from multiple cards" do
      create_commit("[FOO-1] code")
      create_commit("[FOO-2] commit 1 on this card")
      create_commit("[FOO-2] commit 2")
      create_commit("[FOO-2] commit 3")
      number_of_cards = 2
      card_prefix = "FOO"
      card_1_data = Card.new("FOO-1", 1, current_date, current_date)
      card_2_data = Card.new("FOO-2", 3, current_date, current_date)
      subject.card_data(card_prefix).size.should == number_of_cards
      subject.card_data(card_prefix).should include card_1_data
      subject.card_data(card_prefix).should include card_2_data
    end

    it "should not read only part of a card number" do
      create_commit("[FOO-1]")
      create_commit("[FOO-10]")
      create_commit("[FOO-100]")
      subject.card_data("FOO").count.should == 3
      only_one_FOO1 = Card.new("FOO-1", 1, current_date, current_date)
      only_one_FOO10 = Card.new("FOO-10", 1, current_date, current_date)
      subject.card_data("FOO").should include only_one_FOO1
      subject.card_data("FOO").should include only_one_FOO10
    end

    it "does not break on a commit without a card mentioned" do
      card_prefix = "FOO"
      create_commit("whatever")
      subject.card_data(card_prefix).should == []
    end
  end

  describe "#get_card_prefix" do
    it "should see card prefix" do
      subject.get_card_prefix(config).should == "BAZ"
    end
  end

  describe "#card_numbers" do
    card_prefix = "FOO"

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
  end

  describe "#commits_on_card" do
    it "given card name, sees commits on a card" do
      create_commit("[FOO-1]")
      card_name = "FOO-1"
      subject.commits_on_card(card_name).count.should == 1
    end

    it "sees multiple commits on a card" do
      create_commit("[FOO-1] code")
      create_commit("[FOO-1] more code")
      create_commit("[FOO-2] code for other card")
      card_name = "FOO-1"
      subject.commits_on_card(card_name).count.should == 2
    end
  end

  describe "#pretty_card_data" do
    it "pretty output should be human-readable" do
      create_commit("[BAZ-1] code")
      subject.pretty_card_data.should include "BAZ-1 - - - commits: 1 - - - duration: 1 days "
    end
  end
end
