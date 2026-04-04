class CreateLanguageChapterBlockableSetsAndOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :language_chapter_blockable_sets do |t|
      t.references :language, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :prompt_guide
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :language_chapter_blockable_sets, [:language_id, :position],
              name: "index_lc_blockable_sets_on_lang_and_position"

    create_table :language_chapter_blockable_options do |t|
      t.references :language_chapter_blockable_set, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :prompt_guide
      t.string :display, default: "display", null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :language_chapter_blockable_options, [:language_chapter_blockable_set_id, :position],
              name: "index_lc_blockable_opts_on_set_and_position"
  end
end
