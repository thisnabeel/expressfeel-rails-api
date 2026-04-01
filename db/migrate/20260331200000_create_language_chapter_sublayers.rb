class CreateLanguageChapterSublayers < ActiveRecord::Migration[7.1]
  def change
    create_table :language_chapter_sublayers do |t|
      t.references :language, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :language_chapter_sublayers, [:language_id, :position], name: "index_lang_chapter_sublayers_on_lang_and_position"
  end
end
