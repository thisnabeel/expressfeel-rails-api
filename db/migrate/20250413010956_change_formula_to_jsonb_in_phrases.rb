class ChangeFormulaToJsonbInPhrases < ActiveRecord::Migration[7.0]
  def up
    remove_column :phrases, :formula
    add_column :phrases, :formula, :jsonb, null: false, default: { original: [], english: [], roman: [] }
  end

  def down
    remove_column :phrases, :formula
    add_column :phrases, :formula, :text
  end
end
