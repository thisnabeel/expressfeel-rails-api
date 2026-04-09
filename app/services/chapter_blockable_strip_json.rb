# frozen_string_literal: true

# Builds the legacy API shape (one object per blockable set) from physical
# chapter_*_item_blocks rows (one row per tile).
module ChapterBlockableStripJson
  class << self
    def layer_item_strips(item)
      blocks = item.chapter_layer_item_blocks
        .includes(:chapter_layer_item_block_fields, :blockable)
        .order(:position, :id)
        .to_a
      aggregate_strips(blocks)
    end

    def overlay_strips(overlay)
      blocks = overlay.chapter_image_overlay_item_blocks
        .includes(:chapter_image_overlay_item_block_fields, :blockable)
        .order(:position, :id)
        .to_a
      aggregate_strips(blocks)
    end

    # Preloaded `chapter_layer_item_blocks` / overlay blocks in position order (same as +page includes).
    def from_ordered_blocks(blocks)
      aggregate_strips(blocks)
    end

    # Single tile row as a string hash (remix / server reads).
    def row_hash_for_physical_block(block)
      row_hash_from_physical_block(block)
    end

    private

    def aggregate_strips(blocks)
      return [] if blocks.empty?

      blocks.chunk_while { |a, b| same_blockable?(a, b) }.map do |group|
        virtual_strip_json(group)
      end
    end

    def same_blockable?(a, b)
      a.blockable_type == b.blockable_type && a.blockable_id == b.blockable_id
    end

    def virtual_strip_json(group)
      group = group.sort_by { |b| [b.position, b.id] }
      rep = group.first
      d = rep.details.is_a?(Hash) ? rep.details.deep_stringify_keys : {}
      display_keys = d["display_keys"].is_a?(Hash) ? d["display_keys"] : {}

      items_array = group.map { |b| row_hash_from_physical_block(b) }

      block_items = []
      group.each_with_index do |b, tile_idx|
        fields_ordered(b).each do |f|
          block_items << {
            id: f.id,
            tile_index: tile_idx,
            name: f.name,
            content: f.content.to_s,
            display_type: f.display_type,
            position: f.position
          }
        end
      end

      {
        id: rep.id,
        details: { "items" => items_array, "display_keys" => display_keys },
        block_items: block_items,
        position: rep.position,
        blockable_type: rep.blockable_type,
        blockable_id: rep.blockable_id,
        language_chapter_blockable_set: language_chapter_blockable_set_json(rep)
      }
    end

    def row_hash_from_physical_block(block)
      fields_ordered(block).each_with_object({}) do |f, h|
        h[f.name] = f.content.to_s
      end
    end

    def fields_ordered(block)
      case block
      when ChapterLayerItemBlock
        block.chapter_layer_item_block_fields.order(:position, :id)
      when ChapterImageOverlayItemBlock
        block.chapter_image_overlay_item_block_fields.order(:position, :id)
      else
        raise ArgumentError, "Unsupported block: #{block.class.name}"
      end
    end

    def language_chapter_blockable_set_json(block)
      return nil unless block.blockable_type == "LanguageChapterBlockableSet" && block.blockable.present?

      { id: block.blockable.id, title: block.blockable.title }
    end
  end
end
