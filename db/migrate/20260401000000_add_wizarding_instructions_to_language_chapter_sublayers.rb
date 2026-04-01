class AddWizardingInstructionsToLanguageChapterSublayers < ActiveRecord::Migration[7.1]
  def change
    add_column :language_chapter_sublayers, :wizarding_instructions, :text
  end
end
