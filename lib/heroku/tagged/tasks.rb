# HerokuSan.project = HerokuSan::Project.new(
#   Rails.root.join("config","heroku.yml"),
#   :deploy => HerokuSan::Deploy::Tagged
# )

namespace :heroku do
  desc 'displays the deploy config'
  task 'deploy_config' do
    puts HerokuSan.project.configuration.inspect
  end
end