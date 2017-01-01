module PairSee
  class CardsPerPerson
    attr_reader :devs

    def initialize(log_lines, options)
      @log_lines = log_lines
      @options = options
      @devs = _active(options[:names])
    end

    def active_devs(config_file)
      config = YAML.load_file(config_file)
      devs_in_config = config['names'].split(' ')
      devs_in_config.select do |dev|
        _is_active?(dev)
      end
    end
  end
end