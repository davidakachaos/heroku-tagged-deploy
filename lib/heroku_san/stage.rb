# Open the stage class in heroku san and add some methods
require 'auto_tagger'
module HerokuSan
  class Stage
    def tag_repo
      auto_tag = AutoTagger::Base.new(
        stages: HerokuSan.project.stages,
        stage: @name,
        verbose: true,
        push_refs: false,
        refs_to_keep: 10
      )
      tag = auto_tag.create_ref(auto_tag.last_ref_from_previous_stage.try(:sha))
      sh "git push origin #{tag.name}"
      auto_tag.delete_on_remote
      auto_tag.delete_locally
    end
  end
end