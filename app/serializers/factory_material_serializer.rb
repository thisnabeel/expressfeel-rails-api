class FactoryMaterialSerializer < ActiveModel::Serializer
  attributes :id, :materialable_id, :materialable_type, :factory_id
  has_many :factory_material_details
  has_many :material_tags, serializer: MaterialTagSerializer
end
