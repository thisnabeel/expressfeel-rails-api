json.extract! quest, :id, :title, :description, :position, :quest_id, :image_url, :language_id, :difficulty, :created_at, :updated_at
json.url quest_url(quest, format: :json)
