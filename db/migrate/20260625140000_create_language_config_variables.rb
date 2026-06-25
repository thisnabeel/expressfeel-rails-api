class CreateLanguageConfigVariables < ActiveRecord::Migration[7.1]
  def change
    create_table :language_config_variables do |t|
      t.references :language, null: false, foreign_key: true
      t.references :config_variable, foreign_key: { to_table: :language_config_variables }, null: true
      t.string :name, null: false
      t.text :value, null: false, default: ""
      t.string :field_type, null: false, default: "string"
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :language_config_variables, [:language_id, :config_variable_id, :position],
              name: "index_lcv_on_language_parent_position"

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          CREATE UNIQUE INDEX index_lcv_on_language_parent_name
          ON language_config_variables (language_id, COALESCE(config_variable_id, 0), name)
        SQL
      end
      dir.down do
        execute "DROP INDEX IF EXISTS index_lcv_on_language_parent_name"
      end
    end
  end
end
