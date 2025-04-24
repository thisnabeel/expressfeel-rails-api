class Lesson < ActiveRecord::Base
	has_many :lesson_keys, dependent: :destroy
	belongs_to :lesson_plan, optional: true
	# belongs_to :language
	has_many :phrases
	has_many :missions, :through => :phrases

	def filled(id)
		if self.lesson_keys.find_by_language_id(id).present? && self.lesson_keys.find_by_language_id(id).body != "<p></br></p>"
			return true
		else
			return false
		end
	end

	def self.fix
		LessonKey.all.each do |lk|
			if lk.language_id.present?
			elsif lk.language.present?
				lang = lk.language
				language = Language.find_by_title(lk.language)
				lk.update(language_id: language.id)
			end
		end
	end

	def self.get_blanks
		array = []
		Lesson.where.not(objective: nil).each do |l|
			o = l.objective
			word = o.scan(/\{(.*?)\}/)
			word.each {|w| array.push(w[0])}
		end

		return array.uniq
	end
end
