class QuestSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :position, :image_url, :difficulty
  has_one :quest
end
