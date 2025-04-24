class LessonKey < ActiveRecord::Base
	belongs_to :lesson

	has_many :key_phrases

	serialize :folder, coder: JSON

	def find_specific
		return LessonKey.where(lesson_id: params[:lesson_id]).find_by_title(params[:language]) || nil
	end
end
