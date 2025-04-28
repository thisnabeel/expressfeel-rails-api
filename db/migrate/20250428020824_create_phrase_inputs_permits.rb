class CreatePhraseInputsPermits < ActiveRecord::Migration[7.1]
  def change
    create_table :phrase_inputs_permits do |t|
      t.references :phrase_input, null: false, foreign_key: true
      t.references :material_tag_option, null: false, foreign_key: true
      t.boolean :permit

      t.timestamps
    end
  end
end
