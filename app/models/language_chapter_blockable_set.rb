class LanguageChapterBlockableSet < ApplicationRecord
  belongs_to :language
  has_many :language_chapter_blockable_prompt_rules, dependent: :destroy
  has_many :language_chapter_blockable_options, dependent: :destroy
  has_many :chapter_layer_blocks, as: :blockable, dependent: :destroy
  has_many :chapter_image_overlay_blocks, as: :blockable, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :id) }
end
