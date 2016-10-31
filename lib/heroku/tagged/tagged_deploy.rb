module HerokuSan
  module Deploy
    class Tagged < Base

      def get_changes
        say "Getting current tags..."
        `git fetch --tags`
        say "Fetching current state."
        `git fetch #{@stage.name}`
        previous_sha_commit = `git rev-parse HEAD`.strip
        say "Deploying these changes:"
        puts `git log --pretty=format:"* %s" #{@stage.name}/master..#{previous_sha_commit}`
        @file_changes = `git diff --name-only #{previous_sha_commit} #{@stage.name}/master`
      end

      def enable_maintenance_if_needed
        if @file_changes.index("db/migrate") || @file_changes.index("db/seeds.rb")
          say "Migrations found -- enabling maintenance mode..."
          heroku("maintenance:on -a #{@stage.app}")
        end
      end

      def post_changes
        if @file_changes.index("db/migrate")
          say "Running migrations, as there are new ones added."
          heroku("run rake db:migrate -a #{@stage.app}")
        end
        if @file_changes.index("db/seeds.rb")
          say "It looks like you adjusted or created the seeds.rb file."
          say "Running the rake db:seed command now..."
          heroku("run rake db:seed -a #{@stage.app}")
        end
        if @file_changes.index("db/migrate") || @file_changes.index("db/seeds.rb")
          say "Disabling the maintenance mode."
          heroku("maintenance:off -a #{@stage.app}")
          say "Restarting..."
          heroku("restart -a #{@stage.app}")
        end
      end

      def precompile_assets
        `rake RAILS_ENV=production RAILS_GROUP=assets assets:precompile`
        if in_gemfile?('turbo-sprockets-rails3')
          `rake assets:clean_expired`
        end
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
        puts "[#{Time.now.strftime('%H:%M:%S')}][#{@stage.name}] #{text}"
      end

      def deploy
        say "Checking for precompiled assets"
        if File.exist?(::Rails.root.join('public/assets/manifest.yml'))
          say "Found manifest.yml. Precompile assets."
          precompile_assets
        end

        get_changes
        enable_maintenance_if_needed
        
        # Do the deploy
        super
        
        post_changes

        @stage.tag_repo

        say 'Warming up the Heroku dynos'
        sh "curl -o /dev/null http://#{@stage.app}.herokuapp.com"
      end

      private

      def in_gemfile?(reg)
        content = ::Rails.root.join('Gemfile')

        !content.index(reg).nil?
      end
      
      # Executes a command in the Heroku Toolbelt
      def heroku(command)
        system("GEM_HOME='' BUNDLE_GEMFILE='' GEM_PATH='' RUBYOPT='' /usr/local/heroku/bin/heroku #{command}")
      end
    end
  end
end