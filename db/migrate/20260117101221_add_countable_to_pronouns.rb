class AddCountableToPronouns < ActiveRecord::Migration[7.1]
  def change
    add_column :pronouns, :countable, :boolean, default: false, null: false
  end
end
