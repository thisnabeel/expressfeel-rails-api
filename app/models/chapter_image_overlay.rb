class ChapterImageOverlay < ApplicationRecord
  belongs_to :chapter_image

  validates :overlay_type, inclusion: { in: %w[rounded-rect rect ellipse polygon] }
  validates :shape, presence: true
  validates :position, numericality: { only_integer: true }
end
