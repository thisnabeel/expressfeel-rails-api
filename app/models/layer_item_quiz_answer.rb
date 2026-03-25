class LayerItemQuizAnswer < ApplicationRecord
  belongs_to :layer_quiz_question

  validates :position, presence: true, numericality: { only_integer: true }
  validates :correct, inclusion: { in: [true, false] }

  scope :ordered, -> { order(:position, :id) }

  def as_json_for_admin
    {
      id: id,
      layer_quiz_question_id: layer_quiz_question_id,
      original: original,
      english: english,
      position: position,
      correct: correct
    }
  end
end

