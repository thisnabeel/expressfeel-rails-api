class CreateLayerQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :layer_quizzes do |t|
      t.references :chapter_layer, null: false, foreign_key: true
      t.string :title, null: false, default: ""
      t.timestamps
    end
    add_index :layer_quizzes, [:chapter_layer_id, :title]

    create_table :layer_quiz_questions do |t|
      t.references :layer_quiz, null: false, foreign_key: true
      t.text :original, null: false, default: ""
      t.text :english, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :layer_quiz_questions, [:layer_quiz_id, :position]

    create_table :layer_item_quiz_answers do |t|
      t.references :layer_quiz_question, null: false, foreign_key: true
      t.text :original, null: false, default: ""
      t.text :english, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.boolean :correct, null: false, default: false
      t.timestamps
    end
    add_index :layer_item_quiz_answers, [:layer_quiz_question_id, :position]
  end
end

