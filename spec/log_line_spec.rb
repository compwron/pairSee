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

    it "detects SVN-style card" do
      line = " r1196 | committerID | 2013-08-20 18:13:44 -0500 (Tue, 20 Aug 2013) | 2 lines  [FOO9001] Alice and Bob -  commit message"
      LogLine.new(line).contains_card_name?("FOO9001").should == true
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

    it "should recognize date in SVN format line" do
      line = " r1196 | committerID | 2013-08-20 18:13:44 -0500 (Tue, 20 Aug 2013) | 2 lines  [cardNumber] Alice and Bob -  commit message"
      date = LogLine.new(line).date
      date.year.should == 2013
      date.month.should == 8
      date.day.should == 20
    end
  end
end
