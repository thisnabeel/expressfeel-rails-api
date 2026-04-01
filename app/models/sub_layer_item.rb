class SubLayerItem < ApplicationRecord
  ITEMABLE_TYPES = %w[ChapterLayerItem ChapterImageOverlay].freeze

  belongs_to :language_chapter_sublayer
  belongs_to :language
  belongs_to :sublayer_itemable, polymorphic: true

  validates :sublayer_itemable_type, inclusion: { in: ITEMABLE_TYPES }
  validate :language_matches_sublayer

  private

  def language_matches_sublayer
    return unless language_chapter_sublayer && language_id

    if language_id != language_chapter_sublayer.language_id
      errors.add(:language_id, "must match the sublayer's language")
    end
  end
end
