class AddCategoryToPhraseOrderings < ActiveRecord::Migration[7.1]
  def change
    add_column :phrase_orderings, :category, :string
  end
end
