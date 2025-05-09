class RemoveNullConstraintFromMaterialTagOptionId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :phrase_input_permits, :material_tag_option_id, true
  end
end
