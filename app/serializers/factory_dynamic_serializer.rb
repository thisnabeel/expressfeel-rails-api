class FactoryDynamicSerializer < ActiveModel::Serializer
  attributes :id, :factory_id, :factory_dynamic_parameters, :position, :tags, :description, :title, :output_variables, :accepted_inputs, :flow_config, :factory_dynamic_inputs

  def factory_dynamic_inputs
    object.factory_dynamic_inputs.map {|fdi| FactoryDynamicInputSerializer.new(fdi)}
  end
end
