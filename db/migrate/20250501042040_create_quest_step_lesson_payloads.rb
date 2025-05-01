class CreateQuestStepLessonPayloads < ActiveRecord::Migration[7.1]
  def change
    create_table :quest_step_lesson_payloads do |t|
      t.references :quest_step_lesson, null: false, foreign_key: true
      t.string :materialable_type
      t.integer :materialable_id

      t.timestamps
    end
  end
end
