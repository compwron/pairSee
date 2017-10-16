describe PairSee::KnowledgeDebt do
  let(:person1) {PairSee::Person.new(['Person1'])}
  let(:person2) {PairSee::Person.new(['Person2'])}
  let(:multi_name_person) {PairSee::Person.new(%w[Person3 p3  personpersonperson])}
  let(:pair1) {_new_logline('FOO-111: [Person1, Person2] foo')}
  let(:solo1) {_new_logline('FOO-222: [Person1] foo')}
  let(:solo2) {_new_logline('FOO-222: [Person2] foo')}
  let(:solo3) {_new_logline('FOO-333: [Person2] foo')}
  let(:pair2) {_new_logline('FOO-333: [Person2, Person3] foo')}
  let(:solo4) {_new_logline('FOO-444: [Person3] foo')}
  let(:solo5) {_new_logline('FOO-444: [Person3] foo')}
  let(:log_lines) {[pair1, solo1, solo2, solo3, pair2, solo4, solo5]}
  let(:card_prefixes) {["FOO-"]}
  let(:people) {[person1, person2, multi_name_person]}

  subject {PairSee::KnowledgeDebt.new(log_lines, card_prefixes, people).knowledge_debt}

  def _new_logline(msg)
    PairSee::LogLine.new(msg)
  end

  describe '#knowledge_debt' do
    it 'finds debt only when card has pair' do
      expect(subject).to eq ["444 has 2 commits with only 1 committer(s) Person3 on the entire card"]
    end
  end
end
