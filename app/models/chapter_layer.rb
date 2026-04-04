class ChapterLayer < ApplicationRecord
  belongs_to :chapter
  # Bulk delete child items in one SQL statement when a layer is deleted.
  has_many :chapter_layer_items, dependent: :delete_all
  has_many :layer_quizzes, dependent: :delete_all

  validates :position, presence: true, numericality: { only_integer: true }

  before_validation :assign_default_title
  before_validation :clear_other_defaults, if: -> { is_default? && is_default_changed? }
  after_commit :refresh_chapter_default_layer_items_count_cache, on: [:create, :update, :destroy]

  scope :ordered, -> { order(:position, :id) }
  scope :active_only, -> { where(active: true) }

  def as_json_for_viewer(admin:, include_items: true, items_offset: 0, items_limit: nil)
    total_count = chapter_layer_items.count
    scope = chapter_layer_items.order(:position, :id)
    scope = scope.offset(items_offset.to_i) if include_items && items_offset.to_i.positive?
    scope = scope.limit(items_limit.to_i) if include_items && items_limit.present? && items_limit.to_i.positive?
    items = if include_items
      scope.includes(sub_layer_items: :language_chapter_sublayer, chapter_layer_blocks: :blockable).map do |item|
        sub_layer_items_json = item.sub_layer_items.map do |sli|
          {
            id: sli.id,
            language_chapter_sublayer_id: sli.language_chapter_sublayer_id,
            sublayer_name: sli.language_chapter_sublayer&.title,
            body: sli.body,
            hint: sli.hint
          }
        end

        item.as_json.merge(
          "sub_layer_items" => sub_layer_items_json
        )
      end
    else
      []
    end
    loaded_count = items.length
    next_offset = include_items ? items_offset.to_i + loaded_count : 0
    {
      id: id,
      title: title,
      active: active,
      is_default: is_default,
      position: position,
      chapter_layer_items: items,
      chapter_layer_items_count: total_count,
      chapter_layer_items_has_more: include_items ? (next_offset < total_count) : false
    }
  end

  private

  def assign_default_title
    self.title = "Untitled layer" if title.blank?
  end

  def clear_other_defaults
    chapter.chapter_layers.where.not(id: id).update_all(is_default: false)
  end

  def refresh_chapter_default_layer_items_count_cache
    chapter&.refresh_default_layer_caches!
  end
end
