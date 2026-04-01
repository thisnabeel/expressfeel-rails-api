class LanguageChapterSublayer < ApplicationRecord
  belongs_to :language
  has_many :sub_layer_items, dependent: :delete_all

  validates :title, presence: true
  validates :position, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :id) }
end
