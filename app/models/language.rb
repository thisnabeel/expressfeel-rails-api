class Language < ActiveRecord::Base
	has_many :language_traits, dependent: :destroy
	has_many :lesson_keys

	has_many :material_tag_options

	has_many :factories, dependent: :destroy
	has_many :factory_materials, through: :factories

	has_many :factory_dynamics, through: :factories

	has_many :phrases
	has_many :lessons, through: :phrases

	has_many :conjugation_rules, dependent: :destroy
	has_many :noun_rules, dependent: :destroy
	has_many :adjective_rules, dependent: :destroy

	has_many :poems

	has_many :conjugations
	has_many :possessions
	has_many :fragments

	has_many :language_verbs
	has_many :verbs, through: :language_verbs

	has_many :language_nouns
	has_many :nouns, through: :language_nouns

	has_many :language_adjectives
	has_many :adjectives, through: :language_adjectives

	has_many :machines
	has_many :reactions, through: :machines

	def self.populated
		return Language.where(id: Phrase.all.where(ready: true).pluck(:language_id).uniq)
	end

	def self.make_languages
		languages = [
			"MSA Arabic",
			"Egyptian Arabic",
			"Farsi",
			"French",
			"Italian",
			"Spanish",
			"Hebrew",
			"German",
			"Bengali",
			"Japanese",
			"Urdu"
		]

		languages.each do |l|
			if Language.where(title: l).present?
				lang = Language.find_by_title(l)
				LessonKey.where(language: l).update_all(language_id: lang.id)
			else
				lang = Language.create(title: l)
				LessonKey.where(language: l).update_all(language_id: lang.id)
			end
		end
	end

	def sample_material_by_title(title)
		return Factory.find_by(materials_title: title + "s", language_id: self.id).factory_materials.sample
	end

	def random_quiz

		sentence = Phrase.where(language_id: self.id).sample
		expression = sentence.lesson.expression
		objective = sentence.lesson.objective
		answer = sentence.title
		body = sentence.body

		hash = {
			"expression" => expression,
			"objective" => objective,
			"answer" => answer,
			"body" => body,
			"phrase" => sentence
		}

		return hash
	end

	def quiz_count
		return self.language_verbs.count * self.conjugations.count
	end
	
end
