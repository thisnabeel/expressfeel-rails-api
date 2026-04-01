class AddRotationToChapterImageOverlays < ActiveRecord::Migration[7.1]
  def change
    add_column :chapter_image_overlays, :rotation, :integer, null: false, default: 0
  end
end
