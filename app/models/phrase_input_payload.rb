class PhraseInputPayload < ApplicationRecord
  belongs_to :phrase_input
  # belongs_to :factory_dynamic_input
  belongs_to :payloadable, polymorphic: true

  def code
    PhraseInput.find(self.phrase_payload_id).code
  end

  def dynamic_slug
    self.payloadable.slug
  end
end
