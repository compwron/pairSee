require_relative 'spec_helper'

describe Card do
  first_commit_date = Date.new(2012, 1, 1)
  last_commit_date = first_commit_date + 2

  describe '#duration' do
    it 'should see duration of a one-commit card' do
      subject = Card.new 'FOO-1', 1, first_commit_date, first_commit_date
      subject.duration.should == 1
    end

    it 'should see duration of card worked for multiple days' do
      subject = Card.new 'FOO-1', 1, last_commit_date, first_commit_date
      subject.duration.should == 3
    end
  end
end
