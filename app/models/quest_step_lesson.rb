class QuestStepLesson < ApplicationRecord
  belongs_to :lesson
  belongs_to :quest_step
  has_many :quest_step_lesson_payloads, dependent: :destroy

  validates :lesson_id, uniqueness: { scope: :quest_step_id, message: "has already been added to this quest step" }
end