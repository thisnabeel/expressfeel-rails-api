class AddTierToChapters < ActiveRecord::Migration[7.1]
  def up
    add_column :chapters, :tier, :string, null: false, default: "Premium"
    execute <<~SQL.squish
      UPDATE chapters
      SET tier = 'Premium'
      WHERE tier IS NULL
    SQL
  end

  def down
    remove_column :chapters, :tier
  end
end
