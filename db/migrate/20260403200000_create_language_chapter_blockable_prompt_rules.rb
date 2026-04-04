class CreateLanguageChapterBlockablePromptRules < ActiveRecord::Migration[7.1]
  def up
    create_table :language_chapter_blockable_prompt_rules do |t|
      t.references :language_chapter_blockable_set, null: true, foreign_key: true
      t.references :language_chapter_blockable_option, null: true, foreign_key: true
      t.text :body, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end

    add_index :language_chapter_blockable_prompt_rules,
              [:language_chapter_blockable_set_id, :position],
              name: "index_lc_blockable_prompt_rules_on_set_and_position"

    add_index :language_chapter_blockable_prompt_rules,
              [:language_chapter_blockable_option_id, :position],
              name: "index_lc_blockable_prompt_rules_on_opt_and_position"

    add_check_constraint :language_chapter_blockable_prompt_rules,
                         "(language_chapter_blockable_set_id IS NOT NULL AND language_chapter_blockable_option_id IS NULL) OR (language_chapter_blockable_set_id IS NULL AND language_chapter_blockable_option_id IS NOT NULL)",
                         name: "lc_blockable_prompt_rule_one_parent_ck"

    execute <<~SQL.squish
      INSERT INTO language_chapter_blockable_prompt_rules (
        language_chapter_blockable_set_id,
        language_chapter_blockable_option_id,
        body,
        position,
        created_at,
        updated_at
      )
      SELECT id, NULL, TRIM(prompt_guide), 0, NOW(), NOW()
      FROM language_chapter_blockable_sets
      WHERE prompt_guide IS NOT NULL AND LENGTH(TRIM(prompt_guide)) > 0;
    SQL

    execute <<~SQL.squish
      INSERT INTO language_chapter_blockable_prompt_rules (
        language_chapter_blockable_set_id,
        language_chapter_blockable_option_id,
        body,
        position,
        created_at,
        updated_at
      )
      SELECT NULL, id, TRIM(prompt_guide), 0, NOW(), NOW()
      FROM language_chapter_blockable_options
      WHERE prompt_guide IS NOT NULL AND LENGTH(TRIM(prompt_guide)) > 0;
    SQL

    remove_column :language_chapter_blockable_sets, :prompt_guide
    remove_column :language_chapter_blockable_options, :prompt_guide
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Cannot merge prompt rules back into a single prompt_guide column"
  end
end
