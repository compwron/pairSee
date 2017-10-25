describe PairSee::CardsPerPerson do
  describe '#cards_per_person' do
    let(:log_lines) { PairSee::LogLines.new([]) }
    let(:people) { [] }
    let(:card_prefix) {}
    subject { PairSee::CardsPerPerson.new(log_lines, card_prefix, people).cards_per_person }

    it 'should see no cards for a person when there are no cards or people' do
      expect(subject).to eq([])
    end

    describe 'with people but no cards' do
      let(:people) { [PairSee::Person.new(['name'])] }
      it 'should see zero cards for a non-active person' do
        expect(subject).to eq([])
      end
    end

    describe 'with cards but no people' do
      let(:log_lines) { [PairSee::LogLines.new([PairSee::LogLine.new('msg1'), PairSee::LogLine.new('msg2')])] }
      it 'should see no cards for a person' do
        expect(subject).to eq([])
      end
    end

    describe 'with cards and people' do
      let(:log_lines) do
        PairSee::LogLines.new(
          [PairSee::LogLine.new('FOO-1: person1 person2 msg1'),
           PairSee::LogLine.new('FOO-2: person1 msg2')]
        )
      end
      let(:people) { [PairSee::Person.new(['person1']), PairSee::Person.new(['person2'])] }
      let(:card_prefix) { ['FOO-'] }
      it 'should see cards for people' do
        expect(subject).to eq(['person2: [1 cards] 1', 'person1: [2 cards] 1, 2'])
      end
    end
  end
end
