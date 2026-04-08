class Chapter < ApplicationRecord
  belongs_to :language
  belongs_to :parent, class_name: "Chapter", optional: true, foreign_key: :chapter_id, inverse_of: :children
  has_many :children, class_name: "Chapter", foreign_key: :chapter_id, dependent: :destroy, inverse_of: :parent
  has_many :chapter_layers, dependent: :destroy
  has_many :chapter_images, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :chapter_mode, inclusion: { in: %w[text images] }
  validates :tier, inclusion: { in: %w[Free Premium] }
  validate :parent_same_language
  validate :parent_not_cyclic

  after_create :create_default_layer_named_name
  after_commit :renumber_affected_families, on: [:create, :update]
  after_destroy_commit :renumber_former_siblings

  scope :roots, -> { where(chapter_id: nil) }

  def self.tree_for_language(language_id)
    rows = where(language_id: language_id).order(:position).includes(:chapter_layers).to_a
    by_parent = rows.group_by(&:chapter_id)
    build = lambda do |parent_id|
      (by_parent[parent_id] || []).map do |ch|
        default_layer = ch.chapter_layers.find(&:is_default)
        default_layer_id = default_layer&.id
        items_count = ch.default_layer_items_count.to_i
        layers_count = ch.chapter_layers.size
        quiz_count = ch.default_layer_quiz_questions_count.to_i
        # Tiny chapters (single layer, 0–1 items) are not expected to have full lists/quizzes yet.
        skip_small_chapter_warnings = layers_count < 2 && items_count < 2
        {
          id: ch.id,
          title: ch.title,
          description: ch.description,
          chapter_mode: ch.chapter_mode,
          tier: ch.tier,
          hidden: ch.hidden,
          coming_soon: ch.coming_soon,
          chapter_id: ch.chapter_id,
          position: ch.position,
          language_id: ch.language_id,
          default_layer_id: default_layer_id,
          default_layer_items_count: items_count,
          default_layer_items_insufficient: !skip_small_chapter_warnings && items_count <= 1,
          default_layer_quiz_questions_count: quiz_count,
          default_layer_quiz_questions_missing: !skip_small_chapter_warnings && quiz_count <= 0,
          children: build.call(ch.id)
        }
      end
    end
    build.call(nil)
  end

  def descendant_ids
    ids = []
    children.each do |c|
      ids << c.id
      ids.concat(c.descendant_ids)
    end
    ids
  end

  def self.renumber_siblings!(language_id, *parent_ids)
    parent_ids.flatten.compact.uniq.each do |pid|
      where(language_id: language_id, chapter_id: pid).order(:position, :id).each_with_index do |s, i|
        s.update_column(:position, i) if s.position != i
      end
    end
  end

  def renumber_affected_families
    # Sibling order only depends on parent and position; skip when e.g. only hidden/tier/title changed.
    keys = previous_changes.keys.map(&:to_s)
    return unless (keys & %w[chapter_id position language_id]).any?

    families = [chapter_id]
    if previous_changes.key?("chapter_id")
      old_pid = previous_changes["chapter_id"][0]
      families << old_pid if old_pid.present?
    end
    self.class.renumber_siblings!(language_id, families)
  end

  def renumber_former_siblings
    self.class.renumber_siblings!(language_id, chapter_id)
  end

  def refresh_default_layer_caches!
    default_layer_id = chapter_layers.where(is_default: true).pick(:id)
    items_count = default_layer_id ? ChapterLayerItem.where(chapter_layer_id: default_layer_id).count : 0
    quiz_questions_count = if default_layer_id
      LayerQuizQuestion.joins(:layer_quiz).where(layer_quizzes: { chapter_layer_id: default_layer_id }).count
    else
      0
    end
    update_columns(
      default_layer_items_count: items_count,
      default_layer_quiz_questions_count: quiz_questions_count
    )
  end

  def refresh_default_layer_items_count_cache!
    refresh_default_layer_caches!
  end

  private

  def create_default_layer_named_name
    chapter_layers.create!(
      title: "main",
      active: true,
      is_default: true,
      position: 0
    )
  end

  def parent_same_language
    return if chapter_id.blank?

    p = parent
    errors.add(:chapter_id, "must belong to the same language") if p.blank? || p.language_id != language_id
  end

  def parent_not_cyclic
    return if chapter_id.blank?
    return errors.add(:chapter_id, "cannot be self") if chapter_id == id

    if id.present?
      bad = descendant_ids.include?(chapter_id)
      errors.add(:chapter_id, "cannot nest under a descendant") if bad
    end
  end
end
