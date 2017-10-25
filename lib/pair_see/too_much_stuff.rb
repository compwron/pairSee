require 'pry'
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

    def initialize(options)
      @log_lines = LogLineParse.new(options[:repo_locations], options[:after_date]).log_lines
      @active_devs = ActiveDevs.new(@log_lines, options[:names]).devs

      cards_per_person = CardsPerPerson.new(@log_lines, options[:card_prefix], options[:names])
      @devs = cards_per_person.people
      @dev_pairs = cards_per_person.dev_pairs

      @card_prefixes = options[:card_prefix]
    end

    def pretty_card_data
      card_data(@card_prefixes).map do |card|
        card&.pretty
      end
    end

    def pretty_card_data_by_commits
      card_data(@card_prefixes).compact.sort_by.sort_by(&:number_of_commits).reverse.map(&:pretty)
    end

    def card_data(card_prefixes)
      card_prefixes.map do |card_prefix|
        card_numbers(card_prefix).map do |card_name|
          Card.new(card_name, commits_on_card(card_name).sort_by(&:date))
        end
      end.flatten.sort_by(&:duration).reverse
    end

    def commits_on_card(card_name)
      @log_lines.select { |line| line.contains_card_name?(card_name) }
    end

    def card_numbers(card_prefix)
      @log_lines.select do |line|
        line.contains_card?(card_prefix)
      end.map do |line|
        line.card_name([card_prefix])
      end.uniq.compact
    end

    def get_card_prefix(config_file)
      config = YAML.load_file(config_file)
      config['card_prefix']
    end

    def pair_commits
      @dev_pairs.map do |person1, person2|
        log_lines_commits_for_pair = @log_lines.commits_for_pair person1, person2
        PairCommitCount.new(log_lines_commits_for_pair.count, person1, person2)
      end
    end

    def solo_commits
      @devs.map do |dev|
        PairCommitCount.new(@log_lines.solo_commits(@devs, dev).count, dev)
      end
    end

    def all_commits
      pairs_result = Hash[@dev_pairs.map { |k, v| [names_key(k, v), 0] }]
      solos_result = Hash[@devs.map { |k| [k.display_name, 0] }]
      result = pairs_result.merge solos_result

      @log_lines.each do |ll|
        result = method_name(ll, result)
      end
      result
        .sort_by { |_, count| count }
        .reject { |_, count| count == 0 }
        .map { |names, count| "#{names}: #{count}" }
    end

    def method_name(ll, result)
      @dev_pairs.each do |d1, d2|
        if ll.authored_by?(d1, d2)
          result[names_key(d1, d2)] += 1
          return result
        elsif is_solo_by?(@devs, d1, ll)
          result[d1.display_name] += 1
          return result
        elsif is_solo_by?(@devs, d2, ll)
          result[d2.display_name] += 1
          return result
        end
      end
      result
    end

    def is_solo_by?(devs, person, log_line)
      no_other_devs_in_commit = (devs - [person]).none? { |dx| log_line.authored_by?(dx) }
      log_line.authored_by?(person) && no_other_devs_in_commit
    end

    def names_key(k, v)
      [k, v].sort_by(&:display_name).map(&:to_s).join(', ')
    end

    def b(log_line, person1)
      log_line.authored_by?(person1) && (people - [person1]).none? { |single_person| log_line.authored_by?(single_person) }
    end

    def a(log_line, person1, person2)
      log_line.authored_by?(person1, person2)
    end

    def commits_for_pair(person1, person2)
      @log_lines.commits_for_pair person1, person2
    end

    def commits_not_by_known_person
      @log_lines.commits_not_by_known_person @devs
    end

    def most_recent_commit_date(person1, person2)
      recent_commit = commits_for_pair(person1, person2).sort_by(&:date).first
      recent_commit ? recent_commit.date : nil
    end

    def all_most_recent_commits
      @dev_pairs.map do |person1, person2|
        DateCombo.new(most_recent_commit_date(person1, person2), person1, person2)
      end.sort.reverse.map &:to_s
    end

    def recommended_pairings
      should_pair = unpaired_in_range
      should_pair.empty? ? [least_recent_pair] : should_pair
    end

    def least_recent_pair
      devs.select do |person|
        person.names.any? { |name| @log_lines.last.line.match(name) }
      end.map(&:display_name).join(', ')
    end

    def unpaired_in_range
      @dev_pairs.select do |person1, person2|
        most_recent_commit_date(person1, person2).nil?
      end.map do |person1, person2|
        "#{person1}, #{person2}"
      end
    end
  end
end
