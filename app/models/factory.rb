class Factory < ActiveRecord::Base
    belongs_to :language
    has_many :factory_rules
    has_many :reactions
    has_many :factory_materials
    has_many :factory_material_details, through: :factory_materials
    has_many :factory_dynamics
    has_many :factory_dynamic_inputs

    before_create :make_materialable_type

    def make_materialable_type
        unless self.materialable_type.present?
            self.materialable_type = self.materials_title.singularize.capitalize
        end
    end
end
