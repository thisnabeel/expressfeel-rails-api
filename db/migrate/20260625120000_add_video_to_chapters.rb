class AddVideoToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :video_url, :string
    add_column :chapters, :video_original_filename, :string
  end
end
