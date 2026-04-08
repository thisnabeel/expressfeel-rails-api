class ChapterImageOverlayBlock < ApplicationRecord
  belongs_to :chapter_image_overlay
  belongs_to :blockable, polymorphic: true

  validates :position, numericality: { only_integer: true }
  validate :blockable_matches_chapter_language

  scope :ordered, -> { order(:position, :id) }

  def as_json_for_chapter
    {
      id: id,
      details: details,
      position: position,
      blockable_type: blockable_type,
      blockable_id: blockable_id,
      language_chapter_blockable_set: language_chapter_blockable_set_json
    }
  end

  private

  def language_chapter_blockable_set_json
    return nil unless blockable_type == "LanguageChapterBlockableSet" && blockable.present?

    { id: blockable.id, title: blockable.title }
  end

  def blockable_matches_chapter_language
    ch = chapter_image_overlay&.chapter_image&.chapter
    return if ch.blank? || !blockable.respond_to?(:language_id)

    if blockable.language_id != ch.language_id
      errors.add(:blockable, "must belong to the same language as the chapter")
    end
  end
end
