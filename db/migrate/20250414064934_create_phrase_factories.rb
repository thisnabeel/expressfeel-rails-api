class CreatePhraseFactories < ActiveRecord::Migration[7.1]
  def change
    create_table :phrase_factories do |t|
      t.belongs_to :phrase, null: false, foreign_key: true
      t.belongs_to :factory, null: false, foreign_key: true
      t.integer :position
      t.string :code

      t.timestamps
    end
  end
end
