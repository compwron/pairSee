describe PairSee::TooMuchStuff do
  let(:current_date) { Date.today }
  let(:repo) { 'fake_git' }
  let(:after_date) { '0-1-1' }
  let(:g) { Git.init(repo) }

  subject do
    PairSee::TooMuchStuff.new(names: [
                                PairSee::Person.new(['Person1']),
                                PairSee::Person.new(['Person2']),
                                PairSee::Person.new(['Person3']),
                                PairSee::Person.new(['Person4']),
                                PairSee::Person.new(['Person5']),
                                PairSee::Person.new(['Person6']),
                                PairSee::Person.new(['Person7']),
                                PairSee::Person.new(['ActiveDev']),
                                PairSee::Person.new(['InactiveDev'])
                              ],
                              card_prefix: ['BAZ-'],
                              after_date: after_date,
                              repo_locations: [repo])
  end

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

  describe '#card_data' do
    it 'needs to see card names without brackets' do
      create_commit('[FOO-1] one')
      create_commit('FOO-1 two')
      data = subject.card_data(['FOO-'])
      expect(data.size).to eq 1
      expect(data[0].card_name).to eq 'FOO-1'
    end

    it 'in order by duration' do
      create_commit('[FOO-1] one')
      create_commit('[FOO-1] two')
      create_commit('[FOO-1] three')

      create_commit('[FOO-2] one ')
      create_commit('[FOO-2] two ')

      create_commit('[FOO-3] one ')

      data = subject.card_data(['FOO-'])

      expect(data.size).to eq(3)

      expect(data.first.card_name).to eq 'FOO-1'
      expect(data.first.number_of_commits).to eq 3

      expect(data[1].card_name).to eq 'FOO-2'
      expect(data[1].number_of_commits).to eq 2

      expect(data.last.card_name).to eq 'FOO-3'
      expect(data.last.number_of_commits).to eq 1
    end

    it 'gets data from multiple cards' do
      create_commit('[FOO-1] code')
      create_commit('[FOO-2] commit 1 on this card')
      create_commit('[FOO-2] commit 2')
      create_commit('[FOO-2] commit 3')
      number_of_cards = 2
      card_prefixes = ['FOO-']

      data = subject.card_data(card_prefixes)

      expect(data.size).to eq(number_of_cards)
      expect(data[0].card_name).to eq 'FOO-1'
      expect(data[0].number_of_commits).to eq 1
      expect(data[1].card_name).to eq 'FOO-2'
      expect(data[1].number_of_commits).to eq 3
    end

    it 'should not read only part of a card number' do
      create_commit('[FOO-1]')
      create_commit('[FOO-10]')
      create_commit('[FOO-100]')
      data = subject.card_data(['FOO-'])
      expect(data.count).to eq(3)
      expect(data[0].card_name).to eq 'FOO-1'
      expect(data[1].card_name).to eq 'FOO-10'
      expect(data[2].card_name).to eq 'FOO-100'
    end

    it 'does not break on a commit without a card mentioned' do
      create_commit('whatever')
      expect(subject.card_data(['FOO'])).to eq([])
    end
  end

  describe '#get_card_prefix' do
    let(:config) { 'spec/fixtures/spec_config.yml' }
    it 'should see card prefix' do
      create_commit('setup')
      expect(subject.get_card_prefix(config)).to eq(['BAZ-'])
    end
  end

  describe '#card_numbers' do
    card_prefix = 'FOO-'

    it 'sees which cards have been worked' do
      create_commit('[FOO-1]')
      expect(subject.card_numbers(card_prefix)).to eq(['FOO-1'])
    end

    it 'sees multiple card numbers  worked' do
      create_commit('[FOO-1]')
      create_commit('[FOO-2]')
      expect(subject.card_numbers(card_prefix)).to include 'FOO-1'
      expect(subject.card_numbers(card_prefix)).to include 'FOO-2'
      expect(subject.card_numbers(card_prefix).size).to eq(2)
    end
  end

  describe '#commits_on_card' do
    it 'given card name, sees commits on a card' do
      create_commit('[FOO-1]')
      card_name = 'FOO-1'
      expect(subject.commits_on_card(card_name).count).to eq(1)
    end

    it 'sees multiple commits on a card' do
      create_commit('[FOO-1] code')
      create_commit('[FOO-1] more code')
      create_commit('[FOO-2] code for other card')
      card_name = 'FOO-1'
      expect(subject.commits_on_card(card_name).count).to eq(2)
    end
  end

  describe '#pretty_card_data' do
    it 'pretty output should be human-readable' do
      create_commit('[BAZ-1] code')
      expect(subject.pretty_card_data.size).to eq 1
      expect(subject.pretty_card_data[0]).to include 'BAZ-1 - - - commits: 1 - - - duration: 1 days - - - last commit: '
      expect(subject.pretty_card_data[0]).to include '- - - commits per day: 1.0'
    end
  end
end
