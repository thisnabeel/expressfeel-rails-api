class CreateFactoryMaterialDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :factory_material_details do |t|
      t.belongs_to :factory_material, null: false, foreign_key: true
      t.string :slug
      t.string :value
      t.boolean :active
      t.string :category

      t.timestamps
    end
  end
end
