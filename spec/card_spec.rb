describe PairSee::Card do
  first_commit_date = Date.new(2012, 1, 1)
  last_commit_date = first_commit_date + 2

  describe '#duration' do
    it 'should see duration of a one-commit card' do
      subject = PairSee::Card.new 'FOO-1', 1, first_commit_date, first_commit_date
      expect(subject.duration).to eq(1)
    end

    it 'should see duration of card worked for multiple days' do
      subject = PairSee::Card.new 'FOO-1', 1, last_commit_date, first_commit_date
      expect(subject.duration).to eq(3)
    end
  end
end
