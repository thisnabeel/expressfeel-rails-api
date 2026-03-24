class Chapter < ApplicationRecord
  belongs_to :language
  belongs_to :parent, class_name: "Chapter", optional: true, foreign_key: :chapter_id, inverse_of: :children
  has_many :children, class_name: "Chapter", foreign_key: :chapter_id, dependent: :destroy, inverse_of: :parent
  has_many :chapter_layers, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validate :parent_same_language
  validate :parent_not_cyclic

  after_commit :renumber_affected_families, on: [:create, :update]
  after_destroy_commit :renumber_former_siblings

  scope :roots, -> { where(chapter_id: nil) }

  def self.tree_for_language(language_id)
    rows = where(language_id: language_id).order(:position).to_a
    by_parent = rows.group_by(&:chapter_id)
    build = lambda do |parent_id|
      (by_parent[parent_id] || []).map do |ch|
        {
          id: ch.id,
          title: ch.title,
          description: ch.description,
          chapter_id: ch.chapter_id,
          position: ch.position,
          language_id: ch.language_id,
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
    families = [chapter_id]
    families << saved_change_to_chapter_id[0] if saved_change_to_chapter_id?
    self.class.renumber_siblings!(language_id, families)
  end

  def renumber_former_siblings
    self.class.renumber_siblings!(language_id, chapter_id)
  end

  private

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
