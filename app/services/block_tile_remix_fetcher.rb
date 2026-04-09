class BlockTileRemixFetcher
  class UserError < StandardError; end

  class << self
    # Returns: [row_hash, current_value, chapter_language_id]
    def fetch!(context_type:, context_id:, set:, row_index:, field_key:)
      case context_type.to_s
      when "chapter_layer_item"
        item = ChapterLayerItem.find(context_id)
        chapter = item.chapter_layer&.chapter
        raise UserError, "Chapter not found" if chapter.blank?
        raise UserError, "Blockable set belongs to a different language" if set.language_id != chapter.language_id

        physical = physical_block_for_layer_item(item, set, row_index)
        raise UserError, "No block exists for this set on this item" if physical.blank?
        extract_row_from_physical!(physical, field_key).then { |row, val| [row, val, chapter.language_id] }
      when "chapter_image_overlay"
        overlay = ChapterImageOverlay.find(context_id)
        chapter = overlay.chapter_image&.chapter
        raise UserError, "Chapter not found" if chapter.blank?
        raise UserError, "Blockable set belongs to a different language" if set.language_id != chapter.language_id

        physical = physical_block_for_overlay(overlay, set, row_index)
        raise UserError, "No block exists for this set on this overlay" if physical.blank?
        extract_row_from_physical!(physical, field_key).then { |row, val| [row, val, chapter.language_id] }
      else
        raise UserError, "Unknown context_type"
      end
    end

    private

    def physical_block_for_layer_item(item, set, row_index)
      blocks = item.chapter_layer_item_blocks
        .where(blockable_type: set.class.name, blockable_id: set.id)
        .order(:position, :id)
        .to_a
      return if row_index.negative? || row_index >= blocks.size

      blocks[row_index]
    end

    def physical_block_for_overlay(overlay, set, row_index)
      blocks = overlay.chapter_image_overlay_item_blocks
        .where(blockable_type: set.class.name, blockable_id: set.id)
        .order(:position, :id)
        .to_a
      return if row_index.negative? || row_index >= blocks.size

      blocks[row_index]
    end

    def extract_row_from_physical!(physical, field_key)
      row = ChapterBlockableStripJson.row_hash_for_physical_block(physical)
      raise UserError, "Row is not an object" unless row.is_a?(Hash)
      raise UserError, "field_key not found on row" unless row.key?(field_key)

      [row, row[field_key].to_s]
    end
  end
end
