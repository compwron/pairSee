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
  end
end
