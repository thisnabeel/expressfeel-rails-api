class Mission < ActiveRecord::Base
	belongs_to :phrase

	def src 
		begin 
			video = Video.find(self.video).try(:url)
		rescue
			video = ""
		end

		return video
	end
end