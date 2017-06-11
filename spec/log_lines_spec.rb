describe PairSee::LogLines do
  let(:date_string) { "0-1-1" }
  let(:repo) { 'fake_git' }
  let(:git_home) { repo }
  let(:after_date) { '0-1-1' }
  let(:config) { 'spec/fixtures/spec_config.yml' }
  let(:g) { Git.init(repo) }
  let(:person1) {PairSee::Person.new(["Person1"])}
  let(:person2) {PairSee::Person.new(["Person2"])}
  let(:person3) {PairSee::Person.new(["Person3"])}


  subject {
    # temporary to keep tests passing before rewriting them
    g = Git.open(git_home)
    g.config('user.name', 'pairsee-test')
    g.config('user.email', 'pairsee-test@example.com')
    lines = g.log.since(date_string).map do |l|
      PairSee::LogLine.new("#{l.date} #{l.message}")
    end
    PairSee::LogLines.new(lines)
  }

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

  context "with one commit" do
    it "returns the one commit" do
      create_commit("message 123")
      expect(subject.last.to_s).to include "message 123"
    end
  end

  describe "commits_for_pair" do
    it "sees commits for pair" do
      create_commit("FOO-123 [Person1, Person2] aaa")
      create_commit("FOO-123 [Person1, Person3] bbb")
      cfp = subject.commits_for_pair(person1, person2)
      expect(cfp.length).to eq 1
      expect(cfp[0].to_s).to include "aaa"
    end
  end

  describe "active?" do
    it "checks activeness of dev" do
      create_commit("FOO-123 [Person1, Person2] aaa")
      expect(subject.active?(person1)).to be true
      expect(subject.active?(person2)).to be true
      expect(subject.active?(person3)).to be false
    end
  end

  describe "commits_not_by_known_pair" do
    it "detects commits with no known dev name/s" do
      create_commit("FOO-123 [Person1, Person2] aaa")
      create_commit("FOO-123 [Person3] bbb")
      found = subject.commits_not_by_known_pair([person3])
      expect(found.length).to eq 1
      expect(found.to_s).to include "aaa"
    end
  end

  describe "solo_commits" do
    it "is a solo commit if there is only one dev name on it" do
      create_commit("FOO-123 [Person1, Person2] aaa")
      create_commit("FOO-123 [Person3] bbb")
      devs = [person1, person2, person3]
      dev = person3
      solos = subject.solo_commits(devs, dev)
      expect(solos.length).to eq 1
      expect(solos[0].to_s).to include "bbb"
    end
  end
end
