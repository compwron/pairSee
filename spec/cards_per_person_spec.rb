describe PairSee::CardsPerPerson do
  describe '#cards_per_person' do
    subject {PairSee::CardsPerPerson.new(log_lines, card_prefix, people).cards_per_person}
    let(:card_prefix) {['FOO-']}
    let(:person1) {PairSee::Person.new(['person1'])}
    let(:person2) {PairSee::Person.new(['person2'])}
    let(:personless_commit) {PairSee::LogLine.new('[FOO-1] msg1')}
    let(:commit_by_pair) {PairSee::LogLine.new('[FOO-2] person1, person2: msg2')}
    let(:commit_by_person_1) {PairSee::LogLine.new('[FOO-3] person1: msg2')}
    let(:another_commit_by_person_1_same_card) {PairSee::LogLine.new('[FOO-3] person1: msg3')}

    describe 'no commits' do
      let(:log_lines) {PairSee::LogLines.new([])}
      describe 'no people' do
        let(:people) {[]}
        it 'no cards per person' do
          expect(subject).to eq([])
        end
      end

      describe 'with people' do
        let(:people) {[person1]}
        it 'no cards per person' do
          expect(subject).to eq([])
        end
      end
    end

    describe 'with commit without author' do
      let(:log_lines) {PairSee::LogLines.new([personless_commit])}
      describe 'no people' do
        let(:people) {[]}
        it 'no cards per person' do
          expect(subject).to eq([])
        end
      end

      describe 'with people' do
        let(:people) {[person1]}
        it 'one card per person' do
          expect(subject).to eq([])
        end
      end
    end

    describe 'with cards and people' do
      let(:log_lines) {PairSee::LogLines.new([commit_by_pair, commit_by_person_1])}
      let(:people) {[person1, person2]}

      it 'should see cards for people' do
        expect(subject).to eq(['person2: [1 cards] 2', 'person1: [2 cards] 2, 3'])
      end

      describe 'with multiple log lines for one card' do
        let(:log_lines) {PairSee::LogLines.new([commit_by_person_1, another_commit_by_person_1_same_card])}
        it 'counts each card only once' do
          expect(subject).to eq(['person1: [1 cards] 3'])
        end
      end
    end
  end
end