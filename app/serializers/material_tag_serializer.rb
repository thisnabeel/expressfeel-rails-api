class MaterialTagSerializer < ActiveModel::Serializer
  attributes :id, :details

  def details
    object.material_tag_option
  end
end
