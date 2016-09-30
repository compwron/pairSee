describe PairSee::LogLines do
  let(:git_home) { 'spec/fixtures/git' }
  let(:username_config) { 'user.name' }
  let(:username) { 'pairsee1' }
  let(:email_config) { 'user.email' }
  let(:email) { 'a@b.com' }
  let(:commit_message) { 'commit message' }

  before do
    @g = Git.init(git_home)
    @previous_username = @g.config(username_config)
    @previous_email = @g.config(email_config)
    @g.config(username_config, username)
    @g.config(email_config, email)
    `cd #{git_home} ; touch foo.txt`
    @g.add(:all => true)
    @g.commit(commit_message)
  end

  after do
    @g.config(username_config, @previous_username)
    @g.config(email_config, @previous_email)
    `cd #{git_home} ; rm -rf .git`
  end

  subject { PairSee::LogLines.new(git_home, '2010-1-20').lines }
  context 'with commit and author' do
    it 'captures line' do
      expect(subject.count).to eq 1
      commit = subject.first
      expect(commit.author).to eq username
      expect(commit.date).to be
      expect(commit.message).to eq commit_message
    end
  end
end