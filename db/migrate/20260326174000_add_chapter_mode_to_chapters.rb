class AddChapterModeToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :chapter_mode, :string, null: false, default: "text"
  end
end
