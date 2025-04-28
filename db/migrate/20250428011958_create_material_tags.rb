class CreateMaterialTags < ActiveRecord::Migration[7.1]
  def change
    create_table :material_tags do |t|
      t.references :material_tag_option, null: false, foreign_key: true
      t.references :factory_material, null: false, foreign_key: true

      t.timestamps
    end
  end
end
