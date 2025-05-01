class QuestStepLessonPayload < ApplicationRecord
  belongs_to :quest_step_lesson
  belongs_to :materialable, polymorphic: true
end
