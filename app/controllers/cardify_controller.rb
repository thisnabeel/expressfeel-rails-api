class CardifyController < ApplicationController
	def simple
		@mission = params[:id].present? ? Mission.find(params[:id]) : Mission.all.sample
	end
end