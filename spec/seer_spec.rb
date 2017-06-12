describe PairSee::Seer do
  let(:current_date) {Date.today}
  let(:repo) {'fake_git'}
  let(:after_date) {'0-1-1'}
  let(:log_lines) {PairSee::LogLines.new(repo, after_date)}
  let(:g) {Git.init(repo)}

  subject {PairSee::Seer.new({
                                 names: [
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
                                 repo_locations: [repo],
                             })
  }

  def create_commit(message)
    File.open("#{repo}/foo.txt", 'w') {|f| f.puts(message)}
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
    it 'apparently needs to see card names without brackets' do
      create_commit('[FOO-1] one')
      create_commit('FOO-1 two')
      expect(subject.card_data(['FOO-'])).to eq([PairSee::Card.new('FOO-1', 2, current_date, current_date)])
    end

    it 'in order by duration' do
      create_commit('[FOO-1] one')
      create_commit('[FOO-1] two')
      create_commit('[FOO-1] three')

      create_commit('[FOO-2] one ')
      create_commit('[FOO-2] two ')

      create_commit('[FOO-3] one ')

      data = subject.card_data(['FOO-'])

      three_commit_card = PairSee::Card.new('FOO-1', 3, after_date, current_date)
      one_commit_card = PairSee::Card.new('FOO-1', 1, current_date, current_date)

      expect(data.size).to eq(3)
      expect(data.first).to eq(three_commit_card)
      expect(data.last).to eq(one_commit_card)
    end

    it 'gets data from multiple cards' do
      create_commit('[FOO-1] code')
      create_commit('[FOO-2] commit 1 on this card')
      create_commit('[FOO-2] commit 2')
      create_commit('[FOO-2] commit 3')
      number_of_cards = 2
      card_prefixes = ['FOO-']
      card_1_data = PairSee::Card.new('FOO-1', 1, current_date, current_date)
      card_2_data = PairSee::Card.new('FOO-2', 3, current_date, current_date)
      expect(subject.card_data(card_prefixes).size).to eq(number_of_cards)
      expect(subject.card_data(card_prefixes)).to include card_1_data
      expect(subject.card_data(card_prefixes)).to include card_2_data
    end

    it 'should not read only part of a card number' do
      create_commit('[FOO-1]')
      create_commit('[FOO-10]')
      create_commit('[FOO-100]')
      expect(subject.card_data(['FOO-']).count).to eq(3)
      only_one_FOO1 = PairSee::Card.new('FOO-1', 1, current_date, current_date)
      only_one_FOO10 = PairSee::Card.new('FOO-10', 1, current_date, current_date)
      expect(subject.card_data(['FOO-'])).to include only_one_FOO1
      expect(subject.card_data(['FOO-'])).to include only_one_FOO10
    end

    it 'does not break on a commit without a card mentioned' do
      create_commit('whatever')
      expect(subject.card_data(['FOO'])).to eq([])
    end
  end

  describe '#get_card_prefix' do
    let(:config) {'spec/fixtures/spec_config.yml'}
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
      expect(subject.pretty_card_data[0]).to include ('BAZ-1 - - - commits: 1 - - - duration: 1 days - - - last commit: ')
      expect(subject.pretty_card_data[0]).to include ('- - - commits per day: 1.0')
    end
  end
end
