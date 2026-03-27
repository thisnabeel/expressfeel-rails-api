class CreateChapterImages < ActiveRecord::Migration[7.1]
  def change
    create_table :chapter_images do |t|
      t.references :chapter, null: false, foreign_key: true
      t.string :image_url, null: false
      t.string :original_filename
      t.integer :position, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :chapter_images, [:chapter_id, :position]
  end
end
