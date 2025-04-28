class MaterialTag < ApplicationRecord
  belongs_to :material_tag_option
  belongs_to :factory_material
end
