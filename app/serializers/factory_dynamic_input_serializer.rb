class FactoryDynamicInputSerializer < ActiveModel::Serializer
  attributes :id, :slug, :position, :selected_rule, :factory_dynamic_id, :factory_id
  has_many :factory_dynamic_outputs
end
