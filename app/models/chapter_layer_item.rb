class ChapterLayerItem < ApplicationRecord
  belongs_to :chapter_layer

  STYLES = %w[inline header block quote bullet ordered line_break hr].freeze

  validates :position, presence: true, numericality: { only_integer: true }
  validates :style, inclusion: { in: STYLES }
  after_create_commit :refresh_chapter_default_layer_items_count_cache_for_current_layer
  after_destroy_commit :refresh_chapter_default_layer_items_count_cache_for_current_layer
  after_update_commit :refresh_chapter_default_layer_items_count_cache_for_layer_change

  scope :ordered, -> { order(:position, :id) }

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
