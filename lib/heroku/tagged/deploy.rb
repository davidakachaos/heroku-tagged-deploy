require File.join(File.dirname(__FILE__), '../../railtie.rb') if defined?(Rails) && Rails::VERSION::MAJOR >= 3
require 'heroku_san'
require 'rails'
require "heroku/tagged/deploy/version"
require "heroku/tagged/tagged_deploy"
require "heroku/tagged/default_config"
