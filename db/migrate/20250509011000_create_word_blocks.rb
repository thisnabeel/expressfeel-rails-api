class CreateWordBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :word_blocks do |t|
      t.string :original, null: false
      t.string :roman
      t.string :english
      t.references :language, null: false, foreign_key: true

      t.timestamps
    end

    add_index :word_blocks, :original
  end
end


