class PhraseInput < ApplicationRecord
  belongs_to :phrase_inputable, polymorphic: true
  belongs_to :phrase
  has_many :phrase_input_payloads
end
