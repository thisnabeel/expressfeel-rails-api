class CreateFactoryDynamicInputs < ActiveRecord::Migration[7.1]
  def change
    create_table :factory_dynamic_inputs do |t|
      t.string :slug
      t.belongs_to :factory, null: true, foreign_key: true
      t.integer :position
      t.string :selected_rule
      t.belongs_to :factory_dynamic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
