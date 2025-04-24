class PassportPhrase < ActiveRecord::Base
    belongs_to :user
    belongs_to :phrase
    belongs_to :lesson
    belongs_to :language
    after_create :polish

    validates_uniqueness_of :user_id, :scope => [:phrase_id]


    def polish
        phrase = self.phrase
        lesson_id = phrase.lesson_id
        language_id = phrase.language_id
        self.update(lesson_id: lesson_id, language_id: language_id)
	end
end
