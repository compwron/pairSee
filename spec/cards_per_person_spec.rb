describe PairSee::CardsPerPerson do
  let(:card_prefix) { "FOO-" }
  let(:devs) { ["Person1", "Person2"] }
  let(:log_lines) { [PairSee::LogLine.new("FOO-1 [Person1, Person2] some message")] }
  subject { PairSee::CardsPerPerson.new(card_prefix, devs, log_lines).all }

  describe '#all' do
    it 'shows simple map' do
      expect(subject.to_s).to eq "[\"Person1: [1 cards] 1\", \"Person2: [1 cards] 1\"]"
    end
  end
end
