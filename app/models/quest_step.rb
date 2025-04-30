# app/models/quest_step.rb
class QuestStep < ApplicationRecord
  belongs_to :quest

  belongs_to :success_step, class_name: "QuestStep", optional: true
  belongs_to :failure_step, class_name: "QuestStep", optional: true

  has_many :quest_step_lessons
  has_many :lessons, through: :quest_step_lessons

  # If you later make a QuestReward model, you can set up belongs_to :quest_reward, optional: true
end
