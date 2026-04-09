# frozen_string_literal: true

# Splits each former chapter_layer_block (one row per set + many field rows with tile_index)
# into N chapter_layer_item_blocks (one per tile) with chapter_layer_item_block_fields (no tile_index).
# Mirrors the same for image overlay blocks.
class RestructureChapterItemBlocksAndFields < ActiveRecord::Migration[7.1]
  class OldLayerBlock < ActiveRecord::Base
    self.table_name = "chapter_layer_blocks"
  end

  class OldLayerField < ActiveRecord::Base
    self.table_name = "chapter_layer_block_items"
  end

  class OldOverlayBlock < ActiveRecord::Base
    self.table_name = "chapter_image_overlay_blocks"
  end

  class OldOverlayField < ActiveRecord::Base
    self.table_name = "chapter_image_overlay_block_items"
  end

  class TmpLayerBlock < ActiveRecord::Base
    self.table_name = "chapter_layer_item_blocks"
  end

  class TmpLayerField < ActiveRecord::Base
    self.table_name = "chapter_layer_item_block_fields"
  end

  class TmpOverlayBlock < ActiveRecord::Base
    self.table_name = "chapter_image_overlay_item_blocks"
  end

  class TmpOverlayField < ActiveRecord::Base
    self.table_name = "chapter_image_overlay_item_block_fields"
  end

  def up
    create_table :chapter_layer_item_blocks do |t|
      t.references :chapter_layer_item, null: false, foreign_key: { on_delete: :cascade }
      t.jsonb :details, default: {}, null: false
      t.integer :position, default: 0, null: false
      t.string :blockable_type, null: false
      t.bigint :blockable_id, null: false
      t.timestamps
    end
    add_index :chapter_layer_item_blocks, [:blockable_type, :blockable_id],
              name: "index_cl_item_blocks_on_blockable"
    add_index :chapter_layer_item_blocks, [:chapter_layer_item_id, :position],
              name: "index_cl_item_blocks_on_item_and_position"

    create_table :chapter_layer_item_block_fields do |t|
      t.references :chapter_layer_item_block, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.text :content, null: false, default: ""
      t.string :display_type, null: false, default: "expanded"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :chapter_layer_item_block_fields,
              [:chapter_layer_item_block_id, :position],
              name: "index_cl_item_block_fields_on_block_and_pos"

    create_table :chapter_image_overlay_item_blocks do |t|
      t.references :chapter_image_overlay, null: false, foreign_key: { on_delete: :cascade }
      t.jsonb :details, default: {}, null: false
      t.integer :position, default: 0, null: false
      t.string :blockable_type, null: false
      t.bigint :blockable_id, null: false
      t.timestamps
    end
    add_index :chapter_image_overlay_item_blocks, [:blockable_type, :blockable_id],
              name: "index_overlay_item_blocks_on_blockable"
    add_index :chapter_image_overlay_item_blocks, [:chapter_image_overlay_id, :position],
              name: "index_overlay_item_blocks_on_overlay_and_pos"

    create_table :chapter_image_overlay_item_block_fields do |t|
      t.references :chapter_image_overlay_item_block, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.text :content, null: false, default: ""
      t.string :display_type, null: false, default: "expanded"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :chapter_image_overlay_item_block_fields,
              [:chapter_image_overlay_item_block_id, :position],
              name: "index_overlay_item_block_fields_on_block_and_pos"

    [TmpLayerBlock, TmpLayerField, TmpOverlayBlock, TmpOverlayField].each(&:reset_column_information)
    [OldLayerBlock, OldLayerField, OldOverlayBlock, OldOverlayField].each(&:reset_column_information)

    migrate_layer_blocks!
    migrate_overlay_blocks!

    drop_table :chapter_layer_block_items, if_exists: true
    drop_table :chapter_layer_blocks, if_exists: true
    drop_table :chapter_image_overlay_block_items, if_exists: true
    drop_table :chapter_image_overlay_blocks, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def migrate_layer_blocks!
    item_ids = OldLayerBlock.distinct.pluck(:chapter_layer_item_id)
    item_ids.each do |item_id|
      olds = OldLayerBlock.where(chapter_layer_item_id: item_id).order(:position, :id).to_a
      next if olds.empty?

      slots = []
      olds.each do |ob|
        fields = OldLayerField.where(chapter_layer_block_id: ob.id).order(:tile_index, :position, :id).to_a
        if fields.empty?
          slots << { block: ob, field_rows: [] }
        else
          fields.group_by(&:tile_index).sort.each do |_ti, rows|
            slots << { block: ob, field_rows: rows }
          end
        end
      end

      pos = 1
      slots.each do |slot|
        ob = slot[:block]
        nb = TmpLayerBlock.create!(
          chapter_layer_item_id: ob.chapter_layer_item_id,
          details: ob.details || {},
          position: pos,
          blockable_type: ob.blockable_type,
          blockable_id: ob.blockable_id
        )
        pos += 1
        slot[:field_rows].each_with_index do |r, idx|
          TmpLayerField.create!(
            chapter_layer_item_block_id: nb.id,
            name: r.name,
            content: r.content,
            display_type: r.display_type,
            position: idx
          )
        end
      end

      OldLayerBlock.where(id: olds.map(&:id)).delete_all
    end
  end

  def migrate_overlay_blocks!
    overlay_ids = OldOverlayBlock.distinct.pluck(:chapter_image_overlay_id)
    overlay_ids.each do |overlay_id|
      olds = OldOverlayBlock.where(chapter_image_overlay_id: overlay_id).order(:position, :id).to_a
      next if olds.empty?

      slots = []
      olds.each do |ob|
        fields = OldOverlayField.where(chapter_image_overlay_block_id: ob.id).order(:tile_index, :position, :id).to_a
        if fields.empty?
          slots << { block: ob, field_rows: [] }
        else
          fields.group_by(&:tile_index).sort.each do |_ti, rows|
            slots << { block: ob, field_rows: rows }
          end
        end
      end

      pos = 1
      slots.each do |slot|
        ob = slot[:block]
        nb = TmpOverlayBlock.create!(
          chapter_image_overlay_id: ob.chapter_image_overlay_id,
          details: ob.details || {},
          position: pos,
          blockable_type: ob.blockable_type,
          blockable_id: ob.blockable_id
        )
        pos += 1
        slot[:field_rows].each_with_index do |r, idx|
          TmpOverlayField.create!(
            chapter_image_overlay_item_block_id: nb.id,
            name: r.name,
            content: r.content,
            display_type: r.display_type,
            position: idx
          )
        end
      end

      OldOverlayBlock.where(id: olds.map(&:id)).delete_all
    end
  end
end
