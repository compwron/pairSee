module PairSee
  class Seer
    require 'yamler'
    require_relative 'combo'
    require_relative 'date_combo'
    require_relative 'log_lines'
    require_relative 'card'
    require_relative 'cards_per_person'
    require_relative 'sub_seer'

    attr_reader :log_lines, :devs, :dev_pairs, :card_prefix

    def initialize(options)
      @log_lines = _lines_from(options[:repo_location], options[:after_date])
      @sub_seer = SubSeer.new(@log_lines, options)
      @devs = @sub_seer.devs
      @card_prefix = options[:card_prefix]
      @dev_pairs = devs.combination(2)
    end

# seer.commits_not_by_known_pair
# seer.all_most_recent_commits
# seer.recommended_pairings
# seer.pretty_card_data
# seer.cards_per_person
# seer.all_commits


    def cards_per_person
      @sub_seer.cards_per_person
    end

    def _lines_from(git_home, date_string)
      g = Git.open(git_home)
      lines = g.log.since(date_string).map do |l|
        LogLine.new("#{l.date} #{l.message}")
      end
      LogLines.new(lines)
    end

    def pretty_card_data
      card_data(card_prefix).map do |card|
        "#{card.card_name} - - - commits: #{card.number_of_commits} - - - duration: #{card.duration} days " unless card.nil?
      end
    end

    def card_data(card_prefix)
      card_numbers(card_prefix).map do |card_name|
        commits = commits_on_card(card_name)
        Card.new(card_name, commits.count, commits.first.date, commits.last.date)
      end.sort_by(&:duration).reverse
    end

    def commits_on_card(card_name)
      log_lines.select { |line| line.contains_card_name?(card_name) }
    end

    def card_numbers(card_prefix)
      log_lines.select do |line|
        line.contains_card?(card_prefix)
      end.map do |line|
        line.card_name(card_prefix)
      end.uniq.compact
    end

    def get_card_prefix(config_file)
      config = YAML.load_file(config_file)
      config['card_prefix']
    end

    def active_devs(config_file)
      config = YAML.load_file(config_file)
      devs_in_config = config['names'].split(' ')
      devs_in_config.select do |dev|
        _is_active?(dev)
      end
    end

    def pair_commits
      dev_pairs.map do |person1, person2|
        Combo.new(commits_for_pair(person1, person2).count, person1, person2)
      end
    end

    def solo_commits
      devs.map do |dev|
        Combo.new(log_lines.solo_commits(devs, dev).count, dev)
      end
    end

    def all_commits
      (pair_commits + solo_commits).sort_by(&:count).reject(&:empty?).map(&:to_s)
    end

    def commits_for_pair(person1, person2)
      log_lines.commits_for_pair person1, person2
    end

    def commits_not_by_known_pair
      log_lines.commits_not_by_known_pair devs
    end

    def most_recent_commit_date(person1, person2)
      recent_commit = commits_for_pair(person1, person2).sort_by(&:date).first
      recent_commit ? recent_commit.date : nil
    end

    def all_most_recent_commits
      dev_pairs.map do |person1, person2|
        DateCombo.new(most_recent_commit_date(person1, person2), person1, person2)
      end.sort.reverse.map &:to_s
    end

    def recommended_pairings
      should_pair = unpaired_in_range
      should_pair.empty? ? least_recent_pair : should_pair
    end

    def least_recent_pair
      devs.select do |dev|
        log_lines.last.line.match(dev)
      end.join(', ')
    end

    def unpaired_in_range
      dev_pairs.select do |person1, person2|
        most_recent_commit_date(person1, person2).nil?
      end.map do |person1, person2|
        "#{person1}, #{person2}"
      end
    end
  end
end
