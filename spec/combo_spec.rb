describe PairSee::Combo do
  let(:count) { 0 }
  let(:devs) { [] }
  subject { PairSee::Combo.new(count, devs) }
  describe 'empty' do
    it 'returns none' do
      expect(subject.empty?).to be true
    end
  end

  describe 'one pair' do
    let(:count) { 1 }
    let(:devs) { ['person1', 'person2'] }
    it 'is not empty' do
      expect(subject.empty?).to be false
    end

    it 'prints pretty' do
      expect(subject.to_s).to eq 'person1, person2: 1'
    end
  end
end
