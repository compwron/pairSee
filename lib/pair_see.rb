class PairSee
  require 'yamler'
  require_relative 'combo'
  require_relative 'date_combo'
  require_relative 'git_log_lines'
  require_relative 'card'

  attr_reader :log_lines, :devs, :dev_pairs, :card_prefix

  def initialize log_lines, config_file
    @log_lines = log_lines
    @devs = active_devs(config_file)
    @dev_pairs = devs.combination(2)
    @card_prefix = get_card_prefix(config_file)
  end

  def pretty_card_data
    card_data(card_prefix).map { |card|
      "#{card.card_name} - - - commits: #{card.number_of_commits} - - - duration: #{card.duration} days "
    }
  end

  def card_data card_prefix
    card_numbers(card_prefix).map { |card_name|
      commits = commits_on_card(card_name)
      Card.new(card_name, commits.count, commits.first.date, commits.last.date)
    }.sort_by { |card|
      card.duration
    }.reverse
  end

  def commits_on_card card_name
    log_lines.select { |line| line.contains_card_name?(card_name) }
  end

  def card_numbers card_prefix
    log_lines.select { |line|
      line.contains_card?(card_prefix)
    }.map { |line|
      line.card_name(card_prefix)
    }.uniq.compact
  end

  def get_card_prefix config_file
    config = YAML.load_file(config_file)
    config['card_prefix']
  end

  def active_devs config_file
    config = YAML.load_file(config_file)
    devs_in_config = config['names'].split(" ")
    devs_in_config.select { |dev|
      puts "is active? #{dev} #{is_active(dev)}"
      is_active(dev)
    }
  end

  def is_active dev
    puts "ia log lines: #{log_lines}"

    log_lines.active? dev
  end

  def pair_commits
    dev_pairs.map { |person1, person2|
      Combo.new(commits_for_pair(person1, person2).count, person1, person2)
    }
  end

  def solo_commits
    devs.map { |dev|
      Combo.new(log_lines.solo_commits(devs, dev).count, dev)
    }
  end

  def all_commits
    (pair_commits + solo_commits).sort_by(&:count).reject(&:empty?).map(&:to_s)
  end

  def commits_for_pair person1, person2
    log_lines.commits_for_pair person1, person2
  end

  def commits_not_by_known_pair
    log_lines.commits_not_by_known_pair devs
  end

  def most_recent_commit_date person1, person2
    recent_commit = commits_for_pair(person1, person2).sort_by(&:date).first
    recent_commit ? recent_commit.date : nil
  end

  def all_most_recent_commits
    dev_pairs.map { |person1, person2|
      DateCombo.new(most_recent_commit_date(person1, person2), person1, person2)
    }.sort.reverse.map &:to_s
  end

  def recommended_pairings
    should_pair = unpaired_in_range
    should_pair.empty? ? least_recent_pair : should_pair
  end

  def least_recent_pair
    devs.select { |dev|
      log_lines.last.line.match(dev)
    }.join(", ")
  end

  def unpaired_in_range
    dev_pairs.select { |person1, person2|
      most_recent_commit_date(person1, person2).nil?
    }.map { |person1, person2|
      "#{person1}, #{person2}"
    }
  end
end
