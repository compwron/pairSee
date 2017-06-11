describe PairSee::LogLine do
  let(:arnie) {PairSee::Person.new(["Arnie"])}
  let(:person1) {PairSee::Person.new(["Person1"])}
  let(:person2) {PairSee::Person.new(["Person2"])}
  let(:committer2) {PairSee::Person.new(['Committer2'])}
  let(:committer3) {PairSee::Person.new(['Committer3'])}


  def _new_logline(msg)
    PairSee::LogLine.new(msg)
  end

  describe "#card_number" do
    it "sees card number" do
      expect(_new_logline("FOO-123 commit message").card_number(["FOO-"])).to eq "123"
    end
  end

  describe '#contains_card_name?' do
    it 'should see that FOO-51 is card name' do
      card_name = 'FOO-51'
      expect(_new_logline("[#{card_name}]").contains_card_name?(card_name)).to eq(true)
    end

    it 'should not detect FOO-515 as matching card name FOO-51' do
      expect(_new_logline('[FOO-515]').contains_card_name?('FOO-51')).to eq(false)
    end

    it 'should not need brackets to detect card name' do
      expect(_new_logline('FOO-515 stuff').contains_card_name?('FOO-51')).to eq(false)
      expect(_new_logline('FOO-51 other stuff').contains_card_name?('FOO-51')).to eq(true)
    end

    it 'should detect multiple-card commit' do
      expect(_new_logline('[FOO-1, FOO-2] stuff').contains_card_name?('FOO-1')).to eq(true)
      expect(_new_logline('[FOO-1, FOO-2] stuff').contains_card_name?('FOO-2')).to eq(true)
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
      expect(_new_logline(line).card_name(['FOO-'])).to eq('FOO-100')
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
      expect(_new_logline(line).authored_by?(committer2, committer3)).to be_falsey
    end

    it 'should not return true when there are no committers' do
      line = 'stuff'
      expect(_new_logline(line).authored_by?).to be_falsey
    end

    it 'should not wrongly detect committer between Person1 and Person2' do
      line = '2013-11-13 20:38:24 -0800 [Person1] BAZ-200'
      expect(_new_logline(line).authored_by?(person2)).to be_falsey
    end

    it 'should not wrongly detect committer between James and Arnie' do
      line = '2013-11-13 20:38:24 -0800 [James] BAZ-200'
      expect(_new_logline(line).authored_by?(arnie)).to be_falsey
    end

    it 'argh' do
      line = '2013-11-13 22:35:37 -0800 [Person2]'
      expect(_new_logline(line).authored_by?(person1)).to be_falsey
    end

    it 'should detect person in line' do
      line = '[Person1] stuff'
      expect(_new_logline(line).authored_by?(person1)).to be_truthy
    end

    it 'should not detect person in empty line' do
      line = 'stuff'
      expect(_new_logline(line).authored_by?(person1)).to be_falsey
    end

    it 'should not detect other committer in line' do
      line = 'Person1 stuff'
      expect(_new_logline(line).authored_by?(person2)).to be_falsey
    end
  end
end
