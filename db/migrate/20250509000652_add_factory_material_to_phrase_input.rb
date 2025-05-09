class AddFactoryMaterialToPhraseInput < ActiveRecord::Migration[7.1]
  def change
    add_reference :phrase_input_permits, :factory_material, foreign_key: true
  end
end
