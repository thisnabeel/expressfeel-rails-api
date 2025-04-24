class CreatePhraseInputs < ActiveRecord::Migration[7.1]
  def change
    create_table :phrase_inputs do |t|
      t.string :phrase_inputable_type
      t.integer :phrase_inputable_id
      t.string :code
      t.integer :position
      t.integer :phrase_id

      t.timestamps
    end
  end
end
