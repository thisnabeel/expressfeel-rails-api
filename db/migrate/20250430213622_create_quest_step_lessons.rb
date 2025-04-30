class CreateQuestStepLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_step_lessons do |t|
      t.references :lesson, null: false, foreign_key: true
      t.references :quest_step, null: false, foreign_key: true

      t.timestamps
    end
  end
end
