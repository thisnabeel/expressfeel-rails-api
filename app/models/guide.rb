class Guide < ActiveRecord::Base

	after_create :init_position

	def init_position
		self.update(position: Guide.all.order("position ASC").last.position.to_i + 1)
	end
end
