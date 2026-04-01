class CreateSubLayerItems < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_layer_items do |t|
      t.references :language_chapter_sublayer, null: false, foreign_key: true
      t.references :language, null: false, foreign_key: true
      t.text :body
      t.text :hint
      t.string :sublayer_itemable_type, null: false
      t.bigint :sublayer_itemable_id, null: false

      t.timestamps
    end

    add_index :sub_layer_items, [:sublayer_itemable_type, :sublayer_itemable_id], name: "index_sub_layer_items_on_itemable"
  end
end
