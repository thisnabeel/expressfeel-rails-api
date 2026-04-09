class LanguageChapterBlockableSet < ApplicationRecord
  belongs_to :language
  has_many :language_chapter_blockable_prompt_rules, dependent: :destroy
  has_many :language_chapter_blockable_options, dependent: :destroy
  has_many :chapter_layer_item_blocks, as: :blockable, dependent: :destroy
  has_many :chapter_image_overlay_item_blocks, as: :blockable, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :id) }

  # JSON keys on each wizard tile row (same algorithm as the Svelte `uniqueOptionTitles` helper).
  def option_row_keys_by_option_id
    used = {}
    keys = {}
    language_chapter_blockable_options.ordered.each do |o|
      base = o.title.to_s.strip.presence || "option_#{o.id}"
      key = base
      i = 0
      while used[key]
        i += 1
        key = "#{base} (#{i})"
      end
      used[key] = true
      keys[o.id] = key
    end
    keys
  end
end
