class LanguageChapterBlockableOption < ApplicationRecord
  DISPLAY_MODES = %w[display sub expanded].freeze

  belongs_to :language_chapter_blockable_set
  has_many :language_chapter_blockable_prompt_rules, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { only_integer: true }
  validates :display, inclusion: { in: DISPLAY_MODES }

  scope :ordered, -> { order(:position, :id) }
end
