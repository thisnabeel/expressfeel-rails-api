class LayerQuizQuestion < ApplicationRecord
  belongs_to :layer_quiz
  has_many :layer_item_quiz_answers, dependent: :delete_all

  validates :position, presence: true, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :id) }

  def as_json_for_admin
    {
      id: id,
      layer_quiz_id: layer_quiz_id,
      original: original,
      english: english,
      position: position,
      layer_item_quiz_answers: layer_item_quiz_answers.ordered.map(&:as_json_for_admin)
    }
  end
end

