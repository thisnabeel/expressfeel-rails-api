class ChapterImage < ApplicationRecord
  belongs_to :chapter
  has_many :chapter_image_overlays, dependent: :destroy

  validates :image_url, presence: true
  validates :position, numericality: { only_integer: true }

  before_destroy :delete_from_s3

  private

  def delete_from_s3
    return if image_url.blank?

    ImageUploaderService.new.delete_public_url(image_url)
  end
end
