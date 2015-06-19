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

    it "doesn't mind bracketless with immediate colon" do
      expect(_new_logline('FOO-1: stuff').contains_card_name?('FOO-1')).to eq(true)
    end

    it 'detects containment of card name when there is no space between card number and bracket' do
      line = 'FOO-100[bar]'
      expect(_new_logline(line).contains_card_name?('FOO-100')).to eq(true)
    end
  end

  describe '#card_name(prefix)' do
    it 'detects card name when there is no space between card number and bracket' do
      line = 'FOO-100[bar]'
      expect(_new_logline(line).card_name('FOO-')).to eq('FOO-100')
    end
  end

  describe '#date' do
    it 'should recognize date in GIT format line' do
      line = '2012-10-21 10:54:47 -0500 message'
      date = _new_logline(line).date
      expect(date.year).to eq(2012)
      expect(date.month).to eq(10)
      expect(date.day).to eq(21)
    end
  end

  describe '#authored_by?' do
    it 'should not falsely see committer in commit message' do
      line = 'FOO-000 [Committer1, Committer2] commitmessageCommitter3foo'
      expect(_new_logline(line).authored_by?('Committer3', 'Committer2')).to be_falsey
    end

    it 'should not return true when there are no committers' do
      line = 'stuff'
      expect(_new_logline(line).authored_by?).to be_falsey
    end

    it 'should not wrongly detect committer between Person1 and Person2' do
      line = '2013-11-13 20:38:24 -0800 [Person1] BAZ-200'
      expect(_new_logline(line).authored_by?('Person2')).to be_falsey
    end

    it 'should not wrongly detect committer between James and Arnie' do
      line = '2013-11-13 20:38:24 -0800 [James] BAZ-200'
      expect(_new_logline(line).authored_by?('Arnie')).to be_falsey
    end

    it 'argh' do
      line = '2013-11-13 22:35:37 -0800 [Person2]'
      expect(_new_logline(line).authored_by?('Person1')).to be_falsey
    end

    it 'should detect person in line' do
      line = '[Person1] stuff'
      expect(_new_logline(line).authored_by?('Person1')).to be_truthy
    end

    it 'should not detect person in empty line' do
      line = 'stuff'
      expect(_new_logline(line).authored_by?('Person1')).to be_falsey
    end

    it 'should not detect other committer in line' do
      line = 'Person1 stuff'
      expect(_new_logline(line).authored_by?('Person2')).to be_falsey
    end
  end
end
