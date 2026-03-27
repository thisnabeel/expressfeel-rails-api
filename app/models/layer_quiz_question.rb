class LayerQuizQuestion < ApplicationRecord
  belongs_to :layer_quiz
  has_many :layer_item_quiz_answers, dependent: :delete_all

  validates :position, presence: true, numericality: { only_integer: true }
  after_create_commit :refresh_chapter_default_layer_quiz_cache
  after_destroy_commit :refresh_chapter_default_layer_quiz_cache
  after_update_commit :refresh_chapter_default_layer_quiz_cache_for_quiz_change

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

  private

  def refresh_chapter_default_layer_quiz_cache
    layer_quiz&.chapter_layer&.chapter&.refresh_default_layer_caches!
  end

  def refresh_chapter_default_layer_quiz_cache_for_quiz_change
    return unless saved_change_to_layer_quiz_id?

    old_id, new_id = saved_change_to_layer_quiz_id
    old_chapter = Chapter.joins(chapter_layers: :layer_quizzes).where(layer_quizzes: { id: old_id }).first
    new_chapter = Chapter.joins(chapter_layers: :layer_quizzes).where(layer_quizzes: { id: new_id }).first
    old_chapter&.refresh_default_layer_caches!
    new_chapter&.refresh_default_layer_caches!
  end
end

