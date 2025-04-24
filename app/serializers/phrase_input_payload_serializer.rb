class PhraseInputPayloadSerializer < ActiveModel::Serializer
  attributes :id, :phrase_payload_id, :factory_dynamic_input_id
  has_one :phrase_input
end
