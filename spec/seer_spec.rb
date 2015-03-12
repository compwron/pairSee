describe PairSee do
  let(:current_date) { Date.today }
  let(:never) { Date.parse('1970-1-1') }
  let(:repo) { 'fake_git' }
  let(:after_date) { '0-1-1' }
  let(:log_lines) { LogLines.new(repo, after_date) }
  let(:config) { 'spec/spec_config.yml' }
  let(:g) { Git.init(repo) }

  subject { PairSee.new log_lines, config }

  def create_commit(message)
    File.open("#{repo}/foo.txt", 'w') { |f| f.puts(message) }
    g.add
    g.commit(message)
  end

  before do
    g # must create repo before putting a file in it; 'let' is lazy
  end

  after do
    FileUtils.rm_r(repo)
  end

  describe '#all_commits' do
    let(:all_commits) { subject.all_commits }

    it 'contains counts for all pairs which have committed' do
      create_commit('Person1/Person3 code')
      create_commit('Person1/Person3 more code')
      create_commit('Person1/Person2 code')
      expect(all_commits).to include 'Person1, Person3: 2'
      expect(all_commits).to include 'Person1, Person2: 1'
    end

    it "doesn't list counts for pairs who have no commits" do
      create_commit('no pair')
      expect(all_commits).not_to include 'Person2, Person3: 0'
    end

    it "gets all commits which only have person1's name on them" do
      create_commit('Person3 code')
      expect(all_commits).not_to include 'Person1: 0'
      expect(all_commits).to include 'Person3: 1'
    end

    it 'sorts all by count' do
      create_commit('Person1/Person3 code')
      create_commit('Person1/Person3 more code')
      create_commit('Person1/Person2 code')
      expect(all_commits.last).to end_with ': 2'
      expect(all_commits.first).to end_with ': 1'
    end

    context 'with an after date in the future' do
      let(:after_date) { '9999-01-01' }
      it 'can see all commits since a passed-in date' do
        create_commit('a commit before the future after-date')
        expect(all_commits.size).to eq(0)
      end
    end

    it 'sees names with capitalization typos' do
      create_commit('PErson4|person5 thing a thing thing')
      expect(all_commits).to include 'Person4, Person5: 1'
    end

    it "does not wrongfully exclude commits with 'merge' in the message from the count" do
      create_commit('Person5: Merge thing and foo')
      expect(all_commits).to include 'Person5: 1'
    end
  end

  describe '#commits_not_by_known_pair' do
    it 'prints a list of commits it did not connect with a name' do
      create_commit('nameless')
      create_commit('Person1, Person3: code')
      extras = subject.commits_not_by_known_pair.map(&:to_s)
      expect(extras[0]).to include 'nameless'
      expect(extras).not_to include 'Person1, Person3: made cat'
    end

    it 'does not include merge commits in the list of commits without dev names' do
      create_commit("Merge remote-tracking branch 'origin/master'")
      expect(subject.commits_not_by_known_pair).not_to include 'Merge'
    end
  end

  describe '#most_recent_commit_date' do
    it 'sees most recent commit by a pair' do
      create_commit('Person4|Person5 code')
      expect(subject.most_recent_commit_date('Person4', 'Person5')).to eq(current_date)
      expect(subject.most_recent_commit_date('Person4', 'Person1')).to be_nil
    end
  end

  describe '#all_most_recent_commits' do
    it 'gets most recent dates of all pair commits' do
      create_commit('Person1|Person3 code')
      create_commit('Person6')
      expect(subject.all_most_recent_commits).to include "Person1, Person3: #{current_date}"
      expect(subject.all_most_recent_commits).to include 'Person1, Person6: not yet'
    end

    it 'gets most recent dates of all pair commits, sorted temporally' do
      create_commit('Person1|Person2 code')
      create_commit('Person3')
      expect(subject.all_most_recent_commits.first).to include "Person1, Person2: #{current_date}"
      expect(subject.all_most_recent_commits.last).to include 'not yet'
    end
  end

  describe '#unpaired_in_range' do
    it 'recommends pairs based on least recent active dev pair' do
      create_commit('Person1|Person2 code')
      create_commit('ActiveDev code')
      expect(subject.unpaired_in_range).to include 'Person1, ActiveDev'
      expect(subject.unpaired_in_range).not_to include 'Person1, Person2'
    end
  end

  describe '#active_devs' do
    it 'identifies active devs' do
      create_commit('Person1')
      create_commit('ActiveDev')
      active_devs = subject.active_devs(config)

      expect(active_devs).to include 'ActiveDev'
      expect(active_devs).to include 'Person1'
      expect(active_devs).not_to include 'InactiveDev'
    end
  end

  describe '#is_active' do
    it 'is true when the dev is active' do
      create_commit('ActiveDev')
      expect(subject.is_active('ActiveDev')).to be_truthy
      expect(subject.is_active('InactiveDev')).to be_falsey
    end
  end

  describe '#least_recent_pair' do
    it 'sees least recent pairing' do
      create_commit('Person1, Person2')
      create_commit('ActiveDev')
      expect(subject.least_recent_pair).to include 'Person1, Person2'
      expect(subject.least_recent_pair).not_to include 'ActiveDev'
    end
  end

  describe '#cards_per_person' do
    it 'sees that dev has no cards committed on' do
      create_commit('Person1 nocard')
      expect(subject.cards_per_person).to eq(['Person1: [0 cards] '])
    end

    it 'sees that dev has committed on card' do
      create_commit('Person1 BAZ-1')
      expect(subject.cards_per_person).to eq(['Person1: [1 cards] 1'])
    end

    it 'sees multiple cards for multiple devs' do
      create_commit('[Person1, Person2] BAZ-100')
      create_commit('[Person1] BAZ-200')

      expect(subject.cards_per_person).to eq(['Person1: [2 cards] 100, 200', 'Person2: [1 cards] 100'])
    end

    it 'should not think that dev who did not commit on card committed on card just beause dev is in the history' do
      create_commit('[Person2]')
      create_commit('[Person1] BAZ-200')

      expect(subject.cards_per_person).to eq(['Person1: [1 cards] 200', 'Person2: [0 cards] '])
    end

    it 'reports multiple commits by a person on a card only once' do
      create_commit('Person1 Person2 BAZ-1')
      create_commit('Person2 BAZ-1')
      expect(subject.cards_per_person).to eq(['Person1: [1 cards] 1', 'Person2: [1 cards] 1'])
    end
  end
end
