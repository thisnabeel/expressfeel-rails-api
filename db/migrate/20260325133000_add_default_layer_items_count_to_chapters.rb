class AddDefaultLayerItemsCountToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :default_layer_items_count, :integer, null: false, default: 0
  end
end

