require 'rails'

class Railtie < Rails::Railtie
  rake_tasks do
    load File.join(File.dirname(__FILE__), 'heroku/tagged/tasks.rake')
  end
end
