class FactorySerializer < ActiveModel::Serializer
  attributes :id, :name, :materials_title, :rules, :materialable_attributes, :factory_materials, :materialable_type, :factory_dynamics

  def factory_materials
    object.factory_materials
  end

  def factory_dynamics
    object.factory_dynamics.map {|fd| FactoryDynamicSerializer.new(fd)}
  end

  def rules
    object.factory_rules.order("position ASC")
  end

  def materialable_attributes
    className = object.materialable_type
    materialClass = className&.singularize&.capitalize&.constantize
    attrs = []
    if materialClass
        attrs = materialClass.column_names.filter{|key| !["id", "created_at", "updated_at"].include? key }
    end
    return attrs
  end

end