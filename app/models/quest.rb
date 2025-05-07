class Quest < ApplicationRecord
  belongs_to :quest, optional: true
  has_many :quest_steps, dependent: :destroy
  has_many :quest_step_lessons, through: :quest_steps

  def self.popular
    quests = Quest.includes(quest_steps: :quest_step_lessons).to_a
    languages = Language.includes(:phrases).to_a

    phrase_lookup = Phrase.where(ready: true)
                          .pluck(:language_id, :lesson_id)
                          .group_by(&:first)
                          .transform_values { |pairs| pairs.map(&:second).to_set }
    

    quests.each_with_object([]) do |quest, results|
      lesson_ids = quest.quest_step_lessons.map(&:lesson_id).uniq
      next if lesson_ids.empty?

      languages.each do |language|
        lang_lesson_ids = phrase_lookup[language.id] || Set.new
        next unless lesson_ids.all? { |lid| lang_lesson_ids.include?(lid) }

        cover = quest.quest_steps.select { |qs| qs.image_url.present? }.sample&.image_url
        results << {
          quest: quest,
          language: language,
          language_slug: language.title.downcase.parameterize,
          cover: cover
        }
      end
    end
  end
end
