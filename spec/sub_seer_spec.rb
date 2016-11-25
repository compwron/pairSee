describe PairSee::CardsPerPerson do

  describe '#cards_per_person' do
    subject { PairSee::CardsPerPerson.new(log_lines, options).cards_per_person }
    let(:log_lines) { PairSee::LogLines.new([]) }
    let(:options) { {names: []} }
    it "should see no cards for a person when there are no cards or people" do
      expect(subject).to eq([])
    end

    describe "with people but no cards" do
      let(:options) { {names: ["person1", "person2"]} }
      it "should see no cards for a person" do
        expect(subject).to eq([])
      end
    end

    describe "with cards but no people" do
      let(:log_lines) { [PairSee::LogLines.new([PairSee::LogLine.new("msg1"), PairSee::LogLine.new("msg2")])] }
      it "should see no cards for a person" do
        expect(subject).to eq([])
      end
    end

    describe "with cards and people" do
      let(:log_lines) { PairSee::LogLines.new(
          [PairSee::LogLine.new("FOO-1: person1 person2 msg1"),
           PairSee::LogLine.new("FOO-2: person1 msg2")]) }
      let(:options) { {names: ["person1", "person2"], card_prefix: "FOO-"} }
      it "should see cards for people" do
        expect(subject).to eq(["person1: [2 cards] 1, 2", "person2: [1 cards] 1"])
      end
    end
  end
end
