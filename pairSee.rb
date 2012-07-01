require 'yamler'

CONFIG = YAML.load_file("config/config.yml")
GIT_HOME = CONFIG['root']
NAMES = CONFIG['names'].split(" ")

pair_combinations = NAMES.combination(2).to_a
git_log = `git --git-dir=#{GIT_HOME}/.git log --pretty=format:'%s'`.split("\n")

pair_counts = {}

def pair_worked_on_commit(names, log_line)
  (log_line.match(names.split(',').first)) && (log_line.match(names.split(',').last))
end

def get_pair_counts(pair_counts, git_log)
  pair_counts.each do |key, val|
    git_log.each do |log_line|
        if pair_worked_on_commit(key, log_line)
           pair_counts[key] += 1
        end
      end
  end
end

pair_combinations.each do |pair|
  pair_counts[pair.join(',')] = 0
end

def sorted_pair_data(pair_data, sorted_pair_data={})
  pair_data.each do |key, value|
    sorted_pair_data[value] = key
  end
  sorted_pair_data.sort
end

p sorted_pair_data(get_pair_counts pair_counts, git_log)

















