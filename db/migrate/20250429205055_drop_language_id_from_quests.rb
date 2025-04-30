class DropLanguageIdFromQuests < ActiveRecord::Migration[7.1]
  def change
    remove_column :quests, :language_id
  end
end
