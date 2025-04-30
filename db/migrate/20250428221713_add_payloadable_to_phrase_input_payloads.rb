class AddPayloadableToPhraseInputPayloads < ActiveRecord::Migration[7.1]
  def change
    add_column :phrase_input_payloads, :payloadable_type, :string
    add_column :phrase_input_payloads, :payloadable_id, :integer

    add_index :phrase_input_payloads, [:payloadable_type, :payloadable_id]
  end
end
