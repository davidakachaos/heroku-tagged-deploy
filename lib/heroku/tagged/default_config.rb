require 'heroku_san'
if defined?(HerokuSan)
  module HerokuSan
    class Configuration
      def initialize_with_tagged(configurable, stage_factory = HerokuSan::Stage)
        begin
          initialize_without_tagged(configurable, stage_factory = HerokuSan::Stage)
        rescue ArgumentError
          initialize_without_tagged(configurable)
        end
        @options[:deploy] = HerokuSan::Deploy::Tagged
        @options['deploy'] = HerokuSan::Deploy::Tagged
      end

      alias_method :initialize_without_tagged, :initialize
      alias_method :initialize, :initialize_with_tagged
    end
  end
end