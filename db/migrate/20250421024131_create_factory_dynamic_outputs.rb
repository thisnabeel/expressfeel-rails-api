class CreateFactoryDynamicOutputs < ActiveRecord::Migration[7.1]
  def change
    create_table :factory_dynamic_outputs do |t|
      t.string :slug
      t.belongs_to :factory_dynamic_input, null: false, foreign_key: true
      t.string :initial_input_key
      t.integer :position

      t.timestamps
    end
  end
end
