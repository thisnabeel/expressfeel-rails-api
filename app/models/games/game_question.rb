class GameQuestion < ActiveRecord::Base

	belongs_to :game

	serialize :choices, coder: JSON

end