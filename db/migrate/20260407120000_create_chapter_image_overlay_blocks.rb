class CreateChapterImageOverlayBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :chapter_image_overlay_blocks do |t|
      t.references :chapter_image_overlay, null: false, foreign_key: true
      t.jsonb :details, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.string :blockable_type, null: false
      t.bigint :blockable_id, null: false
      t.timestamps
    end

    add_index :chapter_image_overlay_blocks,
              [:blockable_type, :blockable_id],
              name: "index_chapter_image_overlay_blocks_on_blockable"
    add_index :chapter_image_overlay_blocks,
              [:chapter_image_overlay_id, :position],
              name: "index_overlay_blocks_on_overlay_and_position"
  end
end
