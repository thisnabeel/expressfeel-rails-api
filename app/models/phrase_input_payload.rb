class PhraseInputPayload < ApplicationRecord
  belongs_to :phrase_input
  belongs_to :factory_dynamic_input

  def code
    PhraseInput.find(self.phrase_payload_id).code
  end

  def dynamic_slug
    self.factory_dynamic_input.slug
  end
end
