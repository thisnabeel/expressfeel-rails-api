class LanguageConfigVariable < ApplicationRecord
  FIELD_TYPES = %w[integer float string text].freeze

  belongs_to :language
  belongs_to :parent, class_name: "LanguageConfigVariable", optional: true, foreign_key: :config_variable_id, inverse_of: :children
  has_many :children, class_name: "LanguageConfigVariable", foreign_key: :config_variable_id, dependent: :destroy, inverse_of: :parent

  validates :name, presence: true
  validates :value, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :field_type, inclusion: { in: FIELD_TYPES }
  validate :parent_same_language
  validate :parent_not_cyclic
  validate :name_unique_among_siblings
  validate :numeric_value_format

  after_commit :renumber_affected_families, on: [:create, :update]
  after_destroy_commit :renumber_former_siblings

  scope :roots, -> { where(config_variable_id: nil) }

  def self.tree_for_language(language_id)
    rows = where(language_id: language_id).order(:position, :id).to_a
    by_parent = rows.group_by(&:config_variable_id)
    build = lambda do |parent_id|
      (by_parent[parent_id] || []).map do |row|
        {
          id: row.id,
          name: row.name,
          value: row.value,
          field_type: row.field_type,
          config_variable_id: row.config_variable_id,
          position: row.position,
          language_id: row.language_id,
          children: build.call(row.id)
        }
      end
    end
    build.call(nil)
  end

  def descendant_ids
    ids = []
    children.each do |child|
      ids << child.id
      ids.concat(child.descendant_ids)
    end
    ids
  end

  def self.renumber_siblings!(language_id, *parent_ids)
    ids = parent_ids.flatten.uniq
    ids = [nil] if ids.empty?
    ids.each do |pid|
      scope = where(language_id: language_id)
      scope = pid.nil? ? scope.where(config_variable_id: nil) : scope.where(config_variable_id: pid)
      scope.order(:position, :id).each_with_index do |sibling, index|
        sibling.update_column(:position, index) if sibling.position != index
      end
    end
  end

  def renumber_affected_families
    keys = previous_changes.keys.map(&:to_s)
    return unless (keys & %w[config_variable_id position language_id]).any?

    families = [config_variable_id]
    if previous_changes.key?("config_variable_id")
      old_pid = previous_changes["config_variable_id"][0]
      families << old_pid unless families.include?(old_pid)
    end
    self.class.renumber_siblings!(language_id, families)
  end

  def renumber_former_siblings
    self.class.renumber_siblings!(language_id, config_variable_id)
  end

  private

  def parent_same_language
    return if config_variable_id.blank?

    parent_row = parent
    errors.add(:config_variable_id, "must belong to the same language") if parent_row.blank? || parent_row.language_id != language_id
  end

  def parent_not_cyclic
    return if config_variable_id.blank?
    return errors.add(:config_variable_id, "cannot be self") if config_variable_id == id

    if id.present?
      errors.add(:config_variable_id, "cannot nest under a descendant") if descendant_ids.include?(config_variable_id)
    end
  end

  def name_unique_among_siblings
    return if name.blank?

    scope = self.class.where(language_id: language_id, name: name)
    scope = config_variable_id.present? ? scope.where(config_variable_id: config_variable_id) : scope.where(config_variable_id: nil)
    scope = scope.where.not(id: id) if id.present?
    errors.add(:name, "must be unique among siblings") if scope.exists?
  end

  def numeric_value_format
    return if value.blank?

    case field_type
    when "integer"
      errors.add(:value, "must be a valid integer") unless value.to_s.match?(/\A-?\d+\z/)
    when "float"
      errors.add(:value, "must be a valid number") unless value.to_s.match?(/\A-?(?:\d+\.?\d*|\.\d+)\z/)
    end
  end
end
