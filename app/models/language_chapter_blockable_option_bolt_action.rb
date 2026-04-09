# Preset prompts for the per-tile "bolt" menu (AI remix) on a single block-set option.
class LanguageChapterBlockableOptionBoltAction < ApplicationRecord
  belongs_to :language_chapter_blockable_option, inverse_of: :language_chapter_blockable_option_bolt_actions

  validates :prompt, presence: true
  validates :position, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :id) }
end
