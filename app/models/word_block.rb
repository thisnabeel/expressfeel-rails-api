class WordBlock < ApplicationRecord
  belongs_to :language
  has_many :word_block_phrases, dependent: :destroy
  has_many :phrases, through: :word_block_phrases

  validates :original, presence: true
end


