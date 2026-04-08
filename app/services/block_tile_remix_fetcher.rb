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

        blk = item.chapter_layer_blocks.find_by(blockable: set)
        raise UserError, "No block exists for this set on this item" if blk.blank?
        extract_row!(blk.details, row_index, field_key).then { |row, val| [row, val, chapter.language_id] }
      when "chapter_image_overlay"
        overlay = ChapterImageOverlay.find(context_id)
        chapter = overlay.chapter_image&.chapter
        raise UserError, "Chapter not found" if chapter.blank?
        raise UserError, "Blockable set belongs to a different language" if set.language_id != chapter.language_id

        blk = overlay.chapter_image_overlay_blocks.find_by(blockable: set)
        raise UserError, "No block exists for this set on this overlay" if blk.blank?
        extract_row!(blk.details, row_index, field_key).then { |row, val| [row, val, chapter.language_id] }
      else
        raise UserError, "Unknown context_type"
      end
    end

    private

    def extract_row!(details, row_index, field_key)
      d = details.is_a?(Hash) ? details : {}
      items = d["items"]
      raise UserError, "Block has no items array" unless items.is_a?(Array)
      raise UserError, "row_index out of range" if row_index < 0 || row_index >= items.length
      row = items[row_index]
      raise UserError, "Row is not an object" unless row.is_a?(Hash)
      raise UserError, "field_key not found on row" unless row.key?(field_key)
      [row, row[field_key].to_s]
    end
  end
end

