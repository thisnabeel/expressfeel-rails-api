class PhraseInputPermit < ApplicationRecord
  belongs_to :phrase_input
  belongs_to :material_tag_option
end
