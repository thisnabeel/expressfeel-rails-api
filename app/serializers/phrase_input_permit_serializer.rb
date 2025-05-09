class PhraseInputPermitSerializer < ActiveModel::Serializer
  attributes :id, :permit, :title
  has_one :material_tag_option
  has_one :factory_material

  def title
    return object.material_tag_option.title if object.material_tag_option.present?
    if object.factory_material.present?
      details = object.factory_material.factory_material_details.map(&:value).join('; ')
      return "[#{object.factory_material.id}] #{details}"
    end
    nil
  end
end
