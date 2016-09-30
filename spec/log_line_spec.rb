describe PairSee::LogLine do
  let(:commit) { OpenStruct.new(
      message: message,
      date: Time.now,
      author: OpenStruct.new(name: author_name),
      name: 'branch1',
      parent: OpenStruct.new(name: 'branch2')
  )
  }
  let(:author_name) { 'Person1' }
  let(:message) { 'some message' }

  describe '#contains_card_name?' do
    subject { PairSee::LogLine.new(commit).contains_card_name?(card_name) }
    context 'with card name' do
      let(:card_name) { 'FOO-51' }
      let(:message) { card_name + ' some other message stuff' }
      it 'identifies card name' do
        expect(subject).to be true
      end
    end

    context 'with card name containing other card name' do
      let(:card_name) { 'FOO-51' }
      let(:message) { '[FOO-515]' }
      it 'does not detect partial card name' do
        expect(subject).to be false
      end
    end

    context 'with bracketless card name' do
      let(:card_name) { 'FOO-51' }
      let(:message) { 'FOO-51 other stuff' }
      it 'detects card name' do
        expect(subject).to be true
      end
    end

    context 'with multiple cards in commit' do
      let(:message) { '[FOO-1, FOO-2] stuff' }
      let(:card1) { 'FOO-1' }
      let(:card2) { 'FOO-2' }
      it 'detects both cards' do
        expect(PairSee::LogLine.new(commit).contains_card_name?(card1)).to be true
        expect(PairSee::LogLine.new(commit).contains_card_name?(card2)).to be true
      end
    end

    context "bracketless with immediate colon" do
      let(:message) { 'FOO-1: stuff' }
      let(:card_name) { 'FOO-1' }
      it 'detects card name' do
        expect(subject).to be true
      end
    end

    context 'with no space between card number and bracket' do
      let(:message) { 'FOO-100[bar]' }
      let(:card_name) { 'FOO-100' }
      it 'detects containment of card name' do
        expect(subject).to be true
      end
    end
  end

  describe '#card_name(prefix)' do
    subject { PairSee::LogLine.new(commit).card_name(prefix) }
    context 'with no space between card number and bracket' do
      let(:message) { 'FOO-100[bar]' }
      let(:prefix) { 'FOO-' }
      it 'detects card name when there is' do
        expect(subject).to eq 'FOO-100'
      end
    end
  end

  describe '#date' do
    subject { PairSee::LogLine.new(commit).date }
    it 'takes date from commit date' do
      Timecop.freeze(Time.new(2012, 10, 21)) do
        expect(subject.year).to eq(2012)
        expect(subject.month).to eq(10)
        expect(subject.day).to eq(21)
      end
    end
  end

  describe '#authored_by?' do
    subject { PairSee::LogLine.new(commit).authored_by?(*pair) }
    context 'with commiter name as part of a larger word in commit message' do
      let(:message) { 'FOO-000 [Committer1, Committer2] commitmessageCommitter3foo' }
      let(:pair) { ['Committer3', 'Committer2'] }
      it 'does not falsely see committer as author' do
        expect(subject).to be false
      end
    end

    context 'with no committers' do
      let(:message) { 'stuff' }
      let(:author_name) { nil }
      let(:pair) { [] }
      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'with commiter name containing same substring as other committer name' do
      let(:message) { '[Person1] BAZ-200' }
      let(:pair) { ['Person2'] }
      it 'does not wrongly detect committer' do
        expect(subject).to be false
      end
    end

    context 'with names James and Arnie' do
      let(:message) { '[James] BAZ-200' }
      let(:pair) { ['Arnie'] }
      it 'detects committer accurately' do
        expect(subject).to be false
      end
    end

    context 'with author not present in commit' do
      let(:pair) { ['Person1'] }
      let(:author_name) { 'Human' }
      it 'does not detect nonexistant author' do
        expect(subject).to be false
      end
    end
  end
end
