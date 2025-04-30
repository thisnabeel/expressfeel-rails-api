class PhraseOrdering < ApplicationRecord
  belongs_to :phrase

  validate :line_must_be_array

  private

  def line_must_be_array
    errors.add(:line, "must be an array") unless line.is_a?(Array)
  end
end
