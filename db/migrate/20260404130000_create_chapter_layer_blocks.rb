class CreateChapterLayerBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :chapter_layer_blocks do |t|
      t.references :chapter_layer_item, null: false, foreign_key: true
      t.jsonb :details, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.string :blockable_type, null: false
      t.bigint :blockable_id, null: false
      t.timestamps
    end

    add_index :chapter_layer_blocks,
              [:blockable_type, :blockable_id],
              name: "index_chapter_layer_blocks_on_blockable"
    add_index :chapter_layer_blocks,
              [:chapter_layer_item_id, :position],
              name: "index_chapter_layer_blocks_on_item_and_position"
  end
end
