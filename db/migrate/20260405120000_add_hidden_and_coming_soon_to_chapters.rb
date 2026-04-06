class AddHiddenAndComingSoonToChapters < ActiveRecord::Migration[7.1]
  def up
    add_column :chapters, :hidden, :boolean, null: false, default: true
    add_column :chapters, :coming_soon, :boolean, null: false, default: true
    execute "UPDATE chapters SET hidden = false, coming_soon = false"
  end

  def down
    remove_column :chapters, :coming_soon
    remove_column :chapters, :hidden
  end
end
