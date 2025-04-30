class QuestStepLessonSerializer < ActiveModel::Serializer
  attributes :id, :lesson, :lesson_id
  attribute :language_challenge


  def lesson
    object.lesson 
  end

  def language_challenge
    language = instance_options[:language]
    return nil if !language.present?
    phrases = Phrase.where(
      language_id: language.id, 
      lesson_id: object.lesson.id  
    )
    phrase = phrases.sample

    {challenge: phrase.build, blocks: phrase.phrase_word_bank&.words}
  end
end
