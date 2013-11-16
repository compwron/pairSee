require_relative "spec_helper"

describe LogLine do

  describe "#contains_card_name?" do
    it "should see that FOO-51 is card name" do
      card_name = "FOO-51"
      LogLine.new("[#{card_name}]").contains_card_name?(card_name).should == true
    end

    it "should not detect FOO-515 as matching card name FOO-51" do
      LogLine.new("[FOO-515]").contains_card_name?("FOO-51").should == false
    end

    it "should not need brackets to detect card name" do
      LogLine.new("FOO-515 stuff").contains_card_name?("FOO-51").should == false
      LogLine.new("FOO-51 other stuff").contains_card_name?("FOO-51").should == true
    end

    it "should detect multiple-card commit" do
      LogLine.new("[FOO-1, FOO-2] stuff").contains_card_name?("FOO-1").should == true
      LogLine.new("[FOO-1, FOO-2] stuff").contains_card_name?("FOO-2").should == true
    end

    it "doesn't mind bracketless with immediate colon" do
      LogLine.new("FOO-1: stuff").contains_card_name?("FOO-1").should == true
    end

    it "detects containment of card name when there is no space between card number and bracket" do
      line = "FOO-100[bar]"
      LogLine.new(line).contains_card_name?("FOO-100").should == true
    end
  end

  describe "#card_name(prefix)" do
    it "detects card name when there is no space between card number and bracket" do
      line = "FOO-100[bar]"
      LogLine.new(line).card_name("FOO-").should == "FOO-100"
    end
  end

  describe "#date" do
    it "should recognize date in GIT format line" do
      line = "2012-10-21 10:54:47 -0500 message"
      date = LogLine.new(line).date
      date.year.should == 2012
      date.month.should == 10
      date.day.should == 21
    end
  end

  describe "#authored_by?" do
    it "should not falsely see committer in commit message" do
      line = "FOO-000 [Committer1, Committer2] commitmessageCommitter3foo"
      LogLine.new(line).authored_by?("Committer3", "Committer2").should be_false
    end

    it "should not return true when there are no committers" do
      line = "stuff"
      LogLine.new(line).authored_by?().should be_false
    end

    it "should not wrongly detect committer between Person1 and Person2" do
      line = "2013-11-13 20:38:24 -0800 [Person1] BAZ-200"
      LogLine.new(line).authored_by?("Person2").should be_false
    end

    it "should not wrongly detect committer between James and Arnie" do
      line = "2013-11-13 20:38:24 -0800 [James] BAZ-200"
      LogLine.new(line).authored_by?("Arnie").should be_false
    end

    it "argh" do
      line = "2013-11-13 22:35:37 -0800 [Person2]"
      LogLine.new(line).authored_by?("Person1").should be_false
    end

    it "should detect person in line" do
      line = "[Person1] stuff"
      LogLine.new(line).authored_by?("Person1").should be_true
    end

    it "should not detect person in empty line" do
      line = "stuff"
      LogLine.new(line).authored_by?("Person1").should be_false
    end

    it "should not detect other committer in line" do
      line = "Person1 stuff"
      LogLine.new(line).authored_by?("Person2").should be_false
    end
  end
end
