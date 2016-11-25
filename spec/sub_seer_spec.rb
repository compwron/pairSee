describe PairSee::SubSeer do

  describe '#cards_per_person' do
    it 'should see no cards for a person' do
      msg = "FOO-123 Person1 Person2 message"
      log_line = PairSee::LogLine.new(msg)
    end
  end
end
