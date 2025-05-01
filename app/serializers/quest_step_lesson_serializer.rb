class QuestStepLessonSerializer < ActiveModel::Serializer
  attributes :id, :lesson, :lesson_id
  attribute :language_challenge
  attribute :quest_step_lesson_payloads

  belongs_to :lesson

  def quest_step_lesson_payloads
    object.quest_step_lesson_payloads.map do |payload|
      QuestStepLessonPayloadSerializer.new(payload, language: instance_options[:language]).as_json
    end
  end

  def language_challenge
    language = instance_options[:language]
    return nil unless language.present?

    phrases = Phrase.where(language_id: language.id, lesson_id: object.lesson.id)
    phrase = phrases.sample
    materials = object.quest_step_lesson_payloads.map do |p| 
      p.materialable
    end

    if phrase.present?
      {
        challenge: phrase.build_step(materials),
        blocks: phrase.phrase_word_bank.words
      }
    else
      return nil
    end

  end
end
