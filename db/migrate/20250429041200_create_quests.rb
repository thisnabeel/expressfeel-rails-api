class CreateQuests < ActiveRecord::Migration[7.1]
  def change
    create_table :quests do |t|
      t.string :title
      t.text :description
      t.integer :position
      t.belongs_to :quest, null: false, foreign_key: true
      t.string :image_url
      t.belongs_to :language, null: false, foreign_key: true
      t.integer :difficulty

      t.timestamps
    end
  end
end
