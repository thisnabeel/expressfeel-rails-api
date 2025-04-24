class FactoryDynamicOutputSerializer < ActiveModel::Serializer
  attributes :id, :slug, :initial_input_key, :position
  # has_one :factory_dynamic_input
end
