class LayerQuiz < ApplicationRecord
  belongs_to :chapter_layer
  has_many :layer_quiz_questions, dependent: :destroy

  validates :title, presence: true

  def as_json_for_admin
    {
      id: id,
      chapter_layer_id: chapter_layer_id,
      title: title,
      layer_quiz_questions: layer_quiz_questions.ordered.map(&:as_json_for_admin)
    }
  end
end

