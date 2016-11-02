describe PairSee::LogLines do
  let(:date_string) {"0-1-1"}
  let(:repo) { 'fake_git' }
  let(:git_home) {repo}
  let(:after_date) { '0-1-1' }
  let(:log_lines) { PairSee::LogLines.new(repo, after_date) }
  let(:config) { 'spec/fixtures/spec_config.yml' }
  let(:g) { Git.init(repo) }
  subject { PairSee::LogLines.new(git_home, date_string)}

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


  context "with one commits" do
    it "returns the one commit" do
      create_commit("message 123")
      expect(subject.last.to_s).to include "message 123"
    end
  end
end
