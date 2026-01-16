class CreateWordBlockPhrases < ActiveRecord::Migration[7.1]
  def change
    create_table :word_block_phrases do |t|
      t.references :word_block, null: false, foreign_key: true
      t.references :phrase, null: false, foreign_key: true

      t.timestamps
    end

    add_index :word_block_phrases, [:word_block_id, :phrase_id], unique: true, name: "index_word_block_phrases_on_block_and_phrase"
  end
end


