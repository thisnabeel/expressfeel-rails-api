class FactoryMaterialDetail < ApplicationRecord
  belongs_to :factory_material

  VALID_CATEGORIES = %w[original roman core]

  validates :category, inclusion: { in: VALID_CATEGORIES, message: "%{value} is not a valid category" }

  def self.populate_all
    FactoryMaterial.all.each do |fm|
      fm.folder.each do |detail_slug, value|
        category = "core"
        if detail_slug.include? "original"
          category = "original"
        end

        if detail_slug.include? "roman"
          category = "roman"
        end

        if detail_slug.starts_with? "original_"
          next
        end
        if detail_slug.starts_with? "roman_"
          next
        end

        FactoryMaterialDetail.create(
          slug: detail_slug,
          factory_material_id: fm.id,
          value: value,
          active: true,
          category: category
        )
      end
    end
  end
end
