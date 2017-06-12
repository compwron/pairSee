module PairSee
  class Card
    attr_reader :card_name, :number_of_commits, :last_date

    def initialize(card_name, commits)
      @card_name = card_name
      @number_of_commits = commits.count
      @first_date = commits.first.date
      @last_date = commits.last.date
    end

    def duration
      (@last_date - @first_date).to_i + 1
    end

    def ==(other)
      card_name == other.card_name
      number_of_commits == other.number_of_commits
    end

    def pretty
      commits_per_day = ((number_of_commits * 1.0) / duration).round(2)
      "#{card_name} - - - commits: #{number_of_commits} - - - duration: #{duration} days - - - last commit: #{last_date} - - - commits per day: #{commits_per_day}"
    end
  end
end
