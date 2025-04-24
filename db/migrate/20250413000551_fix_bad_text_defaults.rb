class FixBadTextDefaults < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :blocked,   from: "--- []\n", to: "[]"
    change_column_default :users, :friends,   from: "--- []\n", to: "[]"
    change_column_default :users, :followers, from: "--- []\n", to: "[]"
    change_column_default :users, :following, from: "--- []\n", to: "[]"
    change_column_default :users, :peers,     from: "--- []\n", to: "[]"
    change_column_default :users, :requests,  from: "--- {}\n", to: "{}"
  end
end
