# frozen_string_literal: true

# Persists wizard tiles as one physical block per row; fields live on *_item_block_fields.
# API still exposes one virtual strip per blockable set via ChapterBlockableStripJson.
class BlockWizardBlockItemsSync
  SET_TYPE = "LanguageChapterBlockableSet"

  class << self
    # Replace all physical blocks for +set+ on +item+ from client/wizard details hash.
    def replace_layer_strip!(item, set, details_hash)
      replace_strip!(
        parent: item,
        scope_assoc: :chapter_layer_item_blocks,
        field_assoc: :chapter_layer_item_block_fields,
        set: set,
        details_hash: details_hash
      )
    end

    def replace_overlay_strip!(overlay, set, details_hash)
      replace_strip!(
        parent: overlay,
        scope_assoc: :chapter_image_overlay_item_blocks,
        field_assoc: :chapter_image_overlay_item_block_fields,
        set: set,
        details_hash: details_hash
      )
    end

    private

    def replace_strip!(parent:, scope_assoc:, field_assoc:, set:, details_hash:)
      h = deep_stringify(details_hash || {})
      items_arr = h["items"]
      display_keys = h["display_keys"].is_a?(Hash) ? h["display_keys"] : {}
      items_arr = [] unless items_arr.is_a?(Array)

      meta_by_key = BlockableSetWizardPromptBuilder.option_metadata_by_key_for_set(set: set)

      parent.transaction do
        blocks = parent.public_send(scope_assoc).order(:position, :id).to_a
        matches = ->(b) { b.blockable_type == SET_TYPE && b.blockable_id == set.id }
        first_idx = blocks.index(&matches)
        insert_at = first_idx || blocks.size
        num_non_s_before = blocks[0, insert_at]&.count { |b| !matches.call(b) } || 0
        without = blocks.reject(&matches)
        prefix = without[0, num_non_s_before] || []
        suffix = without[num_non_s_before..] || []

        parent.public_send(scope_assoc).where(blockable_type: SET_TYPE, blockable_id: set.id).delete_all

        new_blocks = []
        items_arr.each do |row|
          next unless row.is_a?(Hash)

          nb = create_physical_block!(parent, set, display_keys)
          fill_fields!(nb, field_assoc, row, display_keys, meta_by_key)
          new_blocks << nb
        end

        if new_blocks.empty?
          nb = create_physical_block!(parent, set, display_keys)
          new_blocks << nb
        end

        final = prefix + new_blocks + suffix
        final.each_with_index do |b, i|
          b.update_column(:position, i + 1)
        end
      end
    end

    def create_physical_block!(parent, set, display_keys)
      case parent
      when ChapterLayerItem
        parent.chapter_layer_item_blocks.create!(
          blockable: set,
          details: { "display_keys" => display_keys },
          position: 999_999
        )
      when ChapterImageOverlay
        parent.chapter_image_overlay_item_blocks.create!(
          blockable: set,
          details: { "display_keys" => display_keys },
          position: 999_999
        )
      else
        raise ArgumentError, parent.class.name
      end
    end

    def fill_fields!(physical_block, field_assoc, row, display_keys, meta_by_key)
      assoc = physical_block.public_send(field_assoc)
      assoc.delete_all
      return unless row.is_a?(Hash)

      cells = []
      row.each do |name, raw_val|
        next if name.blank?

        value = scalar_cell_value(raw_val)
        next if value.nil?

        meta = meta_by_key[name.to_s] || {}
        display_type = infer_display_type(name.to_s, display_keys, meta[:display])
        opt_pos = meta[:position]
        cells << {
          name: name.to_s,
          content: value,
          display_type: display_type,
          option_position: opt_pos.is_a?(Integer) ? opt_pos : 999_999
        }
      end

      cells.sort_by! { |c| [c[:option_position], c[:name]] }
      cells.each_with_index do |c, idx|
        assoc.create!(
          name: c[:name],
          content: c[:content],
          display_type: c[:display_type],
          position: idx
        )
      end
    end

    def infer_display_type(name, display_keys, option_display)
      if option_display.present? && LanguageChapterBlockableOption::DISPLAY_MODES.include?(option_display.to_s)
        return option_display.to_s
      end

      pk = display_keys["primary"].presence
      sk = display_keys["sub"].presence
      return "display" if pk.present? && name == pk
      return "sub" if sk.present? && name == sk

      "expanded"
    end

    def scalar_cell_value(raw_val)
      case raw_val
      when nil
        ""
      when String, Numeric, TrueClass, FalseClass
        raw_val.to_s
      else
        nil
      end
    end

    def deep_stringify(hash)
      return {} unless hash.is_a?(Hash)

      hash.deep_stringify_keys
    end
  end
end
