module HerokuSan
  module Deploy
    class Tagged < Base

      def get_changes
        puts "Getting current tags..."
        sh "git fetch --tags"
        puts "[#{@stage.name}] Fetching current state."
        sh "git fetch #{@stage.name}"
        puts "[#{@stage.name}] Deploying..."
        previous_sha_commit = `git rev-parse HEAD`.strip
        puts "[#{@stage.name}] Deploying these changes:"
        puts `git log --pretty=format:"* %s" #{@stage.name}/master..#{previous_sha_commit}`
        puts ""
        @file_changes = `git diff --name-only #{previous_sha_commit} #{@stage.name}/master`
      end

      def enable_maintenance_if_needed
        if @file_changes.index("db/migrate") || @file_changes.index("db/seeds.rb")
          puts "[#{@stage.name}] Migrations found -- enabling maintenance mode..."
          @stage.maintenance(:on)
        end
      end

      def post_changes
        if @file_changes.index("db/migrate")
          puts "[#{@stage.name}] Running migrations, as there are new ones added."
          @stage.migrate
        end
        if @file_changes.index("db/seeds.rb")
          puts "[#{@stage.name}] It looks like you adjusted or created the seeds.rb file."
          puts "[#{@stage.name}] Running the rake db:seed command now..."
          @stage.run('rake db:seed')
        end
        if @file_changes.index("db/migrate") || @file_changes.index("db/seeds.rb")
          puts "[#{@stage.name}] Disabling the maintenance mode."
          stage.maintenance(:off)
          puts "[#{@stage.name}] Restarting..."
          @stage.restart
        end
      end

      def precompile_assets
        sh 'rake RAILS_ENV=production RAILS_GROUP=assets assets:precompile'
        sh 'rake RAILS_GROUP=assets assets:clean_expired'
        if system('git diff --cached --exit-code') == false || system('git diff --exit-code') == false
          sh 'git add -A .'
          sh 'git gc'
          sh "git commit -m 'assets precompiled'"
          sh 'git push'
        else
          puts "No assets changed, no extra commit needed."
        end
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