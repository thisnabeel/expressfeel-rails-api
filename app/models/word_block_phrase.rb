class WordBlockPhrase < ApplicationRecord
  belongs_to :word_block
  belongs_to :phrase

  validates :word_block_id, uniqueness: { scope: :phrase_id }
end


