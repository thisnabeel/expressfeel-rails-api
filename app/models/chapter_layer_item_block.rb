class ChapterLayerItemBlock < ApplicationRecord
  belongs_to :chapter_layer_item
  belongs_to :blockable, polymorphic: true
  has_many :chapter_layer_item_block_fields, dependent: :destroy

  validates :position, numericality: { only_integer: true }
  validate :blockable_matches_chapter_language

  scope :ordered, -> { order(:position, :id) }

  private

  def blockable_matches_chapter_language
    ch = chapter_layer_item&.chapter_layer&.chapter
    return if ch.blank? || !blockable.respond_to?(:language_id)

    if blockable.language_id != ch.language_id
      errors.add(:blockable, "must belong to the same language as the chapter")
    end
  end
end
