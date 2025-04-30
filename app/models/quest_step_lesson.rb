class QuestStepLesson < ApplicationRecord
  belongs_to :lesson
  belongs_to :quest_step

  validates :lesson_id, uniqueness: { scope: :quest_step_id, message: "has already been added to this quest step" }
end