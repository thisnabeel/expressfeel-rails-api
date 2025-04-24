class LessonPlan < ActiveRecord::Base
	has_many :lessons, dependent: :destroy
	has_many :lesson_keys, :through => :lessons
	belongs_to :language

	def random_quiz
		lks = self.lesson_keys
		sentence = lks.sample
		expression = sentence.lesson.expression
		answer = sentence.folder

		hash = {
			"expression" => expression,
			"answer" => answer,
			"id" => sentence.lesson.id
		}

		return hash
	end
end
