class ChapterLayer < ApplicationRecord
  belongs_to :chapter
  # Bulk delete child items in one SQL statement when a layer is deleted.
  has_many :chapter_layer_items, dependent: :delete_all

  validates :position, presence: true, numericality: { only_integer: true }

  before_validation :assign_default_title
  before_validation :clear_other_defaults, if: -> { is_default? && is_default_changed? }

  scope :ordered, -> { order(:position, :id) }
  scope :active_only, -> { where(active: true) }

  def as_json_for_viewer(admin:)
    scope = chapter_layer_items.order(:position, :id)
    {
      id: id,
      title: title,
      active: active,
      is_default: is_default,
      position: position,
      chapter_layer_items: scope.map(&:as_json)
    }
  end

  private

  def assign_default_title
    self.title = "Untitled layer" if title.blank?
  end

  def clear_other_defaults
    chapter.chapter_layers.where.not(id: id).update_all(is_default: false)
  end
end
