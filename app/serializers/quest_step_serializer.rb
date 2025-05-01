# app/serializers/quest_step_serializer.rb
class QuestStepSerializer < ActiveModel::Serializer
  attributes :id,
             :body,
             :position,
             :image_url,
             :thumbnail_url,
             :success_step_id,
             :failure_step_id,
             :quest_reward_id,
             :quest_step_lessons

  def quest_step_lessons
    object.quest_step_lessons.map do |qsl|
      QuestStepLessonSerializer.new(qsl, language: instance_options[:language]).as_json
    end
  end
end
