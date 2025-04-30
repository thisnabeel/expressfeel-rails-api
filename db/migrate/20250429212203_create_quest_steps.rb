class CreateQuestSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_steps do |t|
      t.string :image_url
      t.string :thumbnail_url
      t.references :quest, null: false, foreign_key: true
      t.integer :position
      t.text :body
      t.integer :success_step_id
      t.integer :failure_step_id
      t.integer :quest_reward_id

      t.timestamps
    end
  end
end
