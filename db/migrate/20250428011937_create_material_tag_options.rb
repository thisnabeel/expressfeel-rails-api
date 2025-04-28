class CreateMaterialTagOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :material_tag_options do |t|
      t.references :language, null: false, foreign_key: true
      t.string :title
      t.integer :position

      t.timestamps
    end
  end
end
