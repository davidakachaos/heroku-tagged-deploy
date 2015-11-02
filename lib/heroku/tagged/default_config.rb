module HerokuSan
  class Configuration
    def initialize_with_tagged(configurable, stage_factory = HerokuSan::Stage)
      initialize_without_tagged(configurable, stage_factory = HerokuSan::Stage)
      @options[:deploy] = HerokuSan::Deploy::Tagged
      @options['deploy'] = HerokuSan::Deploy::Tagged
    end

    alias_method :initialize_without_tagged, :initialize
    alias_method :initialize, :initialize_with_tagged
  end
end