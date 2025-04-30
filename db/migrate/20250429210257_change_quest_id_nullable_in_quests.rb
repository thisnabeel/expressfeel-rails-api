class ChangeQuestIdNullableInQuests < ActiveRecord::Migration[7.1]
  def change
    change_column_null :quests, :quest_id, true
  end
end