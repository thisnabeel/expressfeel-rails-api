class ChapterLayerItem < ApplicationRecord
  belongs_to :chapter_layer

  STYLES = %w[inline header block quote bullet ordered line_break hr].freeze

  validates :position, presence: true, numericality: { only_integer: true }
  validates :style, inclusion: { in: STYLES }

  scope :ordered, -> { order(:position, :id) }
end
