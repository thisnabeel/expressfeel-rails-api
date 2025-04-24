class FactoryMaterialDetailSerializer < ActiveModel::Serializer
  attributes :id, :slug, :value, :active, :category
  has_one :factory_material
end
