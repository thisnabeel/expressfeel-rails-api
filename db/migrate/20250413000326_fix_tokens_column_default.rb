class FixTokensColumnDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :tokens, '[]'
  end
end
