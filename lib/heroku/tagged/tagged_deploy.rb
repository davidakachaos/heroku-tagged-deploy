module HerokuSan
  module Deploy
    class Tagged < Base

      def get_changes
        say "Getting current tags..."
        `git fetch --tags`
        say "Fetching current state."
        `git fetch #{@stage.name}`
        say "Deploying..."
        previous_sha_commit = `git rev-parse HEAD`.strip
        say "Deploying these changes:"
        puts `git log --pretty=format:"* %s" #{@stage.name}/master..#{previous_sha_commit}`
        @file_changes = `git diff --name-only #{previous_sha_commit} #{@stage.name}/master`
      end

      def enable_maintenance_if_needed
        if @file_changes.index("db/migrate") || @file_changes.index("db/seeds.rb")
          say "Migrations found -- enabling maintenance mode..."
          `heroku maintenance:on -a #{@stage.app}`
        end
      end

      def post_changes
        if @file_changes.index("db/migrate")
          say "Running migrations, as there are new ones added."
          `heroku run rake db:migrate -a #{@stage.app}`
        end
        if @file_changes.index("db/seeds.rb")
          say "It looks like you adjusted or created the seeds.rb file."
          say "Running the rake db:seed command now..."
          `heroku run rake db:seed -a #{@stage.app}`
        end
        if @file_changes.index("db/migrate") || @file_changes.index("db/seeds.rb")
          say "Disabling the maintenance mode."
          `heroku maintenance:off -a #{@stage.app}`
          say "Restarting..."
          `heroku restart -a #{@stage.app}`
        end
      end

      def precompile_assets
        `rake RAILS_ENV=production RAILS_GROUP=assets assets:precompile`
        `rake RAILS_GROUP=assets assets:clean_expired`
        if system('git diff --cached --exit-code') == false || system('git diff --exit-code') == false
          `git add -A .`
          `git gc`
          `git commit -m 'assets precompiled'`
          `git push`
        else
          say "No assets changed, no extra commit needed."
        end
      end

      def say(text)
        puts "[#{Time.now.strftime('%H:%M %S')}][#{@stage.name}] #{text}"
      end

      def deploy
        if File.exist?(::Rails.root.join('public/assets/manifest.yml'))
          precompile_assets
        end

        get_changes
        enable_maintenance_if_needed
        
        # Do the deploy
        super
        
        post_changes

        @stage.tag_repo
      end
    end
  end
end