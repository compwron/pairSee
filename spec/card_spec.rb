describe PairSee::Card do
  require "ostruct"

  let(:first_commit_date) {Date.new(2012, 1, 1)}
  let(:last_commit_date) {first_commit_date + 2}
  let(:one_commits) {[OpenStruct.new(date: first_commit_date)]}
  let(:two_commits) {[OpenStruct.new(date: first_commit_date), OpenStruct.new(date: last_commit_date)]}

  describe '#duration' do
    it 'should see duration of a one-commit card' do
      subject = PairSee::Card.new 'FOO-1', one_commits
      expect(subject.duration).to eq(1)
    end

    it 'should see duration of card worked for multiple days' do
      subject = PairSee::Card.new 'FOO-1', two_commits
      expect(subject.duration).to eq(3)
    end
  end
end
