class AddHasWordToPronouns < ActiveRecord::Migration[7.1]
  def change
    add_column :pronouns, :has_word, :string
  end
end
