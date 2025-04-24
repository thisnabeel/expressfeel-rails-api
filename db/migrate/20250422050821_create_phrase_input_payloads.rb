class CreatePhraseInputPayloads < ActiveRecord::Migration[7.1]
  def change
    create_table :phrase_input_payloads do |t|
      t.belongs_to :phrase_input, null: false, foreign_key: true
      t.integer :phrase_payload_id
      t.integer :factory_dynamic_input_id

      t.timestamps
    end
  end
end
