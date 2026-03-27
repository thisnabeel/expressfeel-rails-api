class AddDefaultLayerQuizQuestionsCountToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :default_layer_quiz_questions_count, :integer, null: false, default: 0
  end
end

