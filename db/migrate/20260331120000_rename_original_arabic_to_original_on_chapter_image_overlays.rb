class RenameOriginalArabicToOriginalOnChapterImageOverlays < ActiveRecord::Migration[7.1]
  def change
    rename_column :chapter_image_overlays, :original_arabic, :original
  end
end
