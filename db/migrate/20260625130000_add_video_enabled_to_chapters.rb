class AddVideoEnabledToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :video_enabled, :boolean, default: false, null: false
  end
end
