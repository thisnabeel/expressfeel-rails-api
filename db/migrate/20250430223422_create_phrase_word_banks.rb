class CreatePhraseWordBanks < ActiveRecord::Migration[7.1]
  def change
    create_table :phrase_word_banks do |t|
      t.references :phrase, null: false, foreign_key: true
      t.jsonb :words, default: []

      t.timestamps
    end
  end
end
