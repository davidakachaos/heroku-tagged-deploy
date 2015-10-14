module HerokuSan
  class Configuration
    def initialize(configurable, stage_factory = HerokuSan::Stage)
      @config_file = configurable.config_file
      default_options = {
          'deploy' => HerokuSan::Deploy::Tagged
      }
      @options = default_options.merge(configurable.options || {})
      @stage_factory = stage_factory
    end
  end
end