class PhraseDynamicSerializer < ActiveModel::Serializer
  attributes :id, :position, :input_selections, :variable_key, :dynamic

  def dynamic
    object.factory_dynamic
  end
end
