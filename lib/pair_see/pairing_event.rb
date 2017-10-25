module PairSee
  class PairingEvent
    def initialize(current_person, most_recent_commits)
      @current_person = current_person
      @most_recent_commits = most_recent_commits
    end

    def pretty
      @most_recent_commits.sort_by { |_pair, tuple| tuple.first.date }.map do |_pair, tuple|
        "#{@current_person}, #{tuple.last}: #{tuple.first.date}"
      end + _pretty_spacing
    end

    def person
      @current_person
    end

    private

    def _pretty_spacing
      ['']
    end
  end
end
