class CreateChapterImageOverlays < ActiveRecord::Migration[7.1]
  def change
    create_table :chapter_image_overlays do |t|
      t.references :chapter_image, null: false, foreign_key: true
      t.string :overlay_type, null: false
      t.jsonb :shape, null: false, default: {}
      t.string :label
      t.text :original_arabic
      t.text :translation
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :chapter_image_overlays, [:chapter_image_id, :position]
  end
end
