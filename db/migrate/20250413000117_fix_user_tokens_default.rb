class FixUserTokensDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :tokens, from: "--- []", to: '[]'
  end
end
