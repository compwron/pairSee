module PairSee
  class TooMuchStuff
    require 'yamler'
    require_relative 'pair_commit_count'
    require_relative 'date_combo'
    require_relative 'log_lines'
    require_relative 'log_line_parse'
    require_relative 'card'
    require_relative 'cards_per_person'
    require_relative 'active_devs'

    attr_reader :log_lines, :devs, :dev_pairs, :card_prefixes, :cards_per_person

    def initialize(options)
      @log_lines = LogLineParse.new(options[:repo_locations], options[:after_date]).log_lines
      @foo = CardsPerPerson.new(@log_lines, options[:card_prefix], options[:names])
      @active_devs = ActiveDevs.new(@log_lines, options[:names]).devs
      @devs = @foo.people
      @card_prefixes = options[:card_prefix]
      @dev_pairs = @foo.people.combination(2)
      @cards_per_person = @foo.cards_per_person
    end

    def pretty_card_data
      card_data(card_prefixes).map do |card|
        card.pretty unless card.nil?
      end
    end

    def card_data(card_prefixes)
      card_prefixes.map do |card_prefix|
        card_numbers(card_prefix).map do |card_name|
          Card.new(card_name, commits_on_card(card_name).sort_by(&:date))
        end
      end.flatten.sort_by(&:duration).reverse
    end

    def commits_on_card(card_name)
      log_lines.select { |line| line.contains_card_name?(card_name) }
    end

    def card_numbers(card_prefix)
      log_lines.select do |line|
        line.contains_card?(card_prefix)
      end.map do |line|
        line.card_name([card_prefix])
      end.uniq.compact
    end

    def get_card_prefix(config_file)
      config = YAML.load_file(config_file)
      config['card_prefix']
    end

    def active_devs(_config_file)
      @active_devs
    end

    def pair_commits
      dev_pairs.map do |person1, person2|
        PairCommitCount.new(commits_for_pair(person1, person2).count, person1, person2)
      end
    end

    def solo_commits
      devs.map do |dev|
        PairCommitCount.new(log_lines.solo_commits(devs, dev).count, dev)
      end
    end

    def all_commits
      (pair_commits + solo_commits).sort_by(&:count).reject(&:empty?).map(&:to_s)
    end

    def commits_for_pair(person1, person2)
      log_lines.commits_for_pair person1, person2
    end

    def commits_not_by_known_person
      log_lines.commits_not_by_known_person devs
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
      should_pair.empty? ? [least_recent_pair] : should_pair
    end

    def least_recent_pair
      devs.select do |person|
        person.names.any? { |name| log_lines.last.line.match(name) }
      end.map(&:display_name).join(', ')
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
