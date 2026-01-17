class PhraseInputPayload < ApplicationRecord
  belongs_to :phrase_input
  # belongs_to :factory_dynamic_input
  belongs_to :payloadable, polymorphic: true

  def code
    # Cache the result to avoid repeated queries
    @cached_code ||= begin
      if phrase_payload_id.present?
        PhraseInput.find_by(id: phrase_payload_id)&.code
      else
        phrase_input&.code
      end
    end
  end

  def dynamic_slug
    self.payloadable&.slug
  end
end
