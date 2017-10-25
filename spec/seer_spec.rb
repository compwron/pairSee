describe PairSee::Seer do

  let(:repo_locations) {[]}
  let(:after_date) {"2017-09-01"}
  let(:card_prefix) {"DOO-"}
  let(:names) {["Person1", "Person2"]}

  let(:options) {{
      repo_locations: repo_locations,
      after_date: after_date,
      card_prefix: card_prefix,
      names: names
  }}
  subject {PairSee::Seer.new(options)}

  describe '#commits_not_by_known_pair' do
    it 'calls TooMuchStuff.commits_not_by_known_pair' do
      expect(subject.commits_not_by_known_pair).to eq []
    end
  end
end
