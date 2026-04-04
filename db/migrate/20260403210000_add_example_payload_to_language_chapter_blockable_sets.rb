class AddExamplePayloadToLanguageChapterBlockableSets < ActiveRecord::Migration[7.1]
  def change
    add_column :language_chapter_blockable_sets, :example_payload, :text
  end
end
