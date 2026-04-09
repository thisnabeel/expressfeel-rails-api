class ChapterLayerItem < ApplicationRecord
  belongs_to :chapter_layer
  has_many :sub_layer_items, as: :sublayer_itemable, dependent: :destroy
  has_many :chapter_layer_item_blocks, dependent: :destroy

  STYLES = %w[inline header block quote bullet ordered line_break hr].freeze

  validates :position, presence: true, numericality: { only_integer: true }
  validates :style, inclusion: { in: STYLES }
  after_create_commit :refresh_chapter_default_layer_items_count_cache_for_current_layer
  after_destroy_commit :refresh_chapter_default_layer_items_count_cache_for_current_layer
  after_update_commit :refresh_chapter_default_layer_items_count_cache_for_layer_change

  scope :ordered, -> { order(:position, :id) }

  def as_json(options = {})
    super(options).merge(
      "chapter_layer_blocks" => chapter_layer_blocks_as_json
    )
  end

  # When parent scope uses .includes(chapter_layer_item_blocks: [:blockable, :chapter_layer_item_block_fields]), use memory only — do not
  # chain .order on the association (that bypasses the preload and causes one SQL query per item).
  def chapter_layer_blocks_as_json
    if association(:chapter_layer_item_blocks).loaded?
      blocks = chapter_layer_item_blocks.sort_by { |b| [b.position || 0, b.id || 0] }
      ChapterBlockableStripJson.from_ordered_blocks(blocks)
    else
      ChapterBlockableStripJson.layer_item_strips(self)
    end
  end

  private

  def refresh_chapter_default_layer_items_count_cache_for_current_layer
    chapter = chapter_layer&.chapter || Chapter.joins(:chapter_layers).where(chapter_layers: { id: chapter_layer_id }).first
    chapter&.refresh_default_layer_caches!
  end

  def refresh_chapter_default_layer_items_count_cache_for_layer_change
    return unless saved_change_to_chapter_layer_id?

    old_layer_id, new_layer_id = saved_change_to_chapter_layer_id
    old_chapter = Chapter.joins(:chapter_layers).where(chapter_layers: { id: old_layer_id }).first
    new_chapter = Chapter.joins(:chapter_layers).where(chapter_layers: { id: new_layer_id }).first
    old_chapter&.refresh_default_layer_caches!
    new_chapter&.refresh_default_layer_caches!
  end
end
