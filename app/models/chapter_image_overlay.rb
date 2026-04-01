class ChapterImageOverlay < ApplicationRecord
  belongs_to :chapter_image

  ALLOWED_ROTATIONS = [0, 90, 180, 270].freeze

  validates :overlay_type, inclusion: { in: %w[rounded-rect rect ellipse polygon] }
  validates :shape, presence: true
  validates :position, numericality: { only_integer: true }
  validates :rotation, inclusion: { in: ALLOWED_ROTATIONS }
end
