class UserMission < ActiveRecord::Base
    belongs_to :user
    belongs_to :mission
    belongs_to :language
    belongs_to :lesson
    after_create :polish

    validates_uniqueness_of :user_id, :scope => [:mission_id]


    def polish
        mission = self.mission
        lesson_id = mission.phrase.lesson_id
        language_id = mission.phrase.language_id
        self.update(lesson_id: lesson_id, language_id: language_id)
	end
end
