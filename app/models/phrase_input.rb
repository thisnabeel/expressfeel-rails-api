class PhraseInput < ApplicationRecord
  belongs_to :phrase_inputable, polymorphic: true
  belongs_to :phrase
  has_many :phrase_input_payloads, dependent: :destroy
  has_many :phrase_input_permits, dependent: :destroy
end
