class MaterialTagOptionSerializer < ActiveModel::Serializer
  attributes :id, :title, :position
  has_one :language
end
