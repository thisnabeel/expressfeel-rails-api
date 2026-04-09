class CreateLanguageChapterBlockableOptionBoltActions < ActiveRecord::Migration[7.1]
  def change
    create_table :language_chapter_blockable_option_bolt_actions do |t|
      t.references :language_chapter_blockable_option, null: false, foreign_key: true
      t.text :prompt, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :language_chapter_blockable_option_bolt_actions,
              [:language_chapter_blockable_option_id, :position],
              name: "index_lc_blockable_bolt_actions_on_opt_and_position"
  end
end
