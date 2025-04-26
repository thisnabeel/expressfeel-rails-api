class AddProperBooleanToNoun < ActiveRecord::Migration[7.1]
  def change
    add_column :nouns, :proper, :boolean, default: false
    add_column :nouns, :quantity, :integer, default: 1
  end
end
