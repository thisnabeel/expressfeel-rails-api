class CreateChaptersAndLayers < ActiveRecord::Migration[7.1]
  def change
    create_table :chapters do |t|
      t.string :title, null: false
      t.text :description
      t.references :chapter, foreign_key: { to_table: :chapters }, null: true
      t.integer :position, null: false, default: 0
      t.references :language, null: false, foreign_key: true

      t.timestamps
    end

    add_index :chapters, [:language_id, :chapter_id, :position]

    create_table :chapter_layers do |t|
      t.references :chapter, null: false, foreign_key: true
      t.string :title, null: false, default: ""
      t.boolean :active, null: false, default: true
      t.boolean :is_default, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :chapter_layers, [:chapter_id, :position]

    create_table :chapter_layer_items do |t|
      t.references :chapter_layer, null: false, foreign_key: true
      t.text :body
      t.string :style, null: false, default: "inline"
      t.text :hint
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :chapter_layer_items, [:chapter_layer_id, :position]
  end
end
