require 'rails'

module Heroku::Tagged::Deploy
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tagged/tasks.rb'
    end
  end
end
