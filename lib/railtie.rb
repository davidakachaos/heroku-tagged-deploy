require 'rails'

module Heroku::Tagged::Deploy
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'heroku/tagged/tasks.rb')
    end
  end
end
