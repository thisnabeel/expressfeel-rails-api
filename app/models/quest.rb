class Quest < ApplicationRecord
  belongs_to :quest, optional: true
  has_many :quest_steps, dependent: :destroy
end
