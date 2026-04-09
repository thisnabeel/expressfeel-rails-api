class ChapterImageOverlayItemBlockField < ApplicationRecord
  belongs_to :chapter_image_overlay_item_block

  validates :name, presence: true
  validates :position, numericality: { only_integer: true }
  validates :display_type, inclusion: { in: LanguageChapterBlockableOption::DISPLAY_MODES }

  scope :ordered_for_row, -> { order(:position, :id) }
end
