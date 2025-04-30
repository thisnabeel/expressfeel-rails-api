class CreatePhraseOrderings < ActiveRecord::Migration[7.1]
  def change
    create_table :phrase_orderings do |t|
      t.jsonb :line, default: []
      t.text :description
      t.integer :position
      t.references :phrase, null: false, foreign_key: true

      t.timestamps
    end
  end
end
