class PhraseInputPermit < ApplicationRecord
  belongs_to :phrase_input
  belongs_to :material_tag_option, optional: :true
  belongs_to :factory_material, optional: :true

  validate :material_tag_option_or_factory_material_must_exist

  private

  def material_tag_option_or_factory_material_must_exist
    if material_tag_option_id.blank? && factory_material_id.blank?
      errors.add(:base, "Either material_tag_option or factory_material must be present")
    end
  end
end
