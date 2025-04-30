# app/serializers/quest_step_serializer.rb
class QuestStepSerializer < ActiveModel::Serializer
  attributes :id,
             :body,
             :position,
             :image_url,
             :thumbnail_url,
             :success_step_id,
             :failure_step_id,
             :quest_reward_id

end
