class PhraseInputPermitSerializer < ActiveModel::Serializer
  attributes :id, :permit
  has_one :material_tag_option
end
