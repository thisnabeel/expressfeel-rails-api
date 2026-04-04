class LanguageChapterBlockablePromptRule < ApplicationRecord
  belongs_to :language_chapter_blockable_set, optional: true
  belongs_to :language_chapter_blockable_option, optional: true

  validates :body, presence: true
  validates :position, numericality: { only_integer: true }
  validate :exactly_one_parent

  scope :ordered, -> { order(:position, :id) }

  private

  def exactly_one_parent
    has_set = language_chapter_blockable_set_id.present?
    has_option = language_chapter_blockable_option_id.present?
    return if has_set ^ has_option

    errors.add(:base, "must belong to exactly one blockable set or one blockable option")
  end
end
