class ChangeFolderToJsonbInFactoryMaterials < ActiveRecord::Migration[7.0]
  def change
    remove_column :factory_materials, :folder

    add_column :factory_materials, :folder, :jsonb, default: {}, null: false
  end
end
