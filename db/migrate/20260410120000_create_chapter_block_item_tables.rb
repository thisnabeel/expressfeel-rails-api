class CreateChapterBlockItemTables < ActiveRecord::Migration[7.1]
  def up
    create_table :chapter_layer_block_items do |t|
      t.references :chapter_layer_block, null: false, foreign_key: { on_delete: :cascade }
      t.integer :tile_index, null: false, default: 0
      t.string :name, null: false
      t.text :content, null: false, default: ""
      t.string :display_type, null: false, default: "expanded"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :chapter_layer_block_items,
              [:chapter_layer_block_id, :tile_index, :position],
              name: "index_cl_block_items_on_block_tile_pos"

    create_table :chapter_image_overlay_block_items do |t|
      t.references :chapter_image_overlay_block, null: false, foreign_key: { on_delete: :cascade }
      t.integer :tile_index, null: false, default: 0
      t.string :name, null: false
      t.text :content, null: false, default: ""
      t.string :display_type, null: false, default: "expanded"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :chapter_image_overlay_block_items,
              [:chapter_image_overlay_block_id, :tile_index, :position],
              name: "index_overlay_block_items_on_block_tile_pos"

    say_with_time "Backfilling block items from legacy details JSON" do
      ChapterLayerBlock.reset_column_information
      ChapterImageOverlayBlock.reset_column_information
      ChapterLayerBlock.find_each do |block|
        next unless block.details.is_a?(Hash)

        BlockWizardBlockItemsSync.sync!(block, block.details.deep_stringify_keys)
      end
      ChapterImageOverlayBlock.find_each do |block|
        next unless block.details.is_a?(Hash)

        BlockWizardBlockItemsSync.sync!(block, block.details.deep_stringify_keys)
      end
    end
  end

  def down
    say_with_time "Restoring details.items from normalized rows" do
      ChapterLayerBlock.find_each do |block|
        block.update_columns(details: BlockWizardBlockItemsSync.details_json_for_api(block))
      end
      ChapterImageOverlayBlock.find_each do |block|
        block.update_columns(details: BlockWizardBlockItemsSync.details_json_for_api(block))
      end
    end

    drop_table :chapter_image_overlay_block_items, if_exists: true
    drop_table :chapter_layer_block_items, if_exists: true
  end
end
