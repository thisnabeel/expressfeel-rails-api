class Game < ActiveRecord::Base

	belongs_to :gameable
	
	has_many :game_questions

	serialize :folder, coder: JSON

end