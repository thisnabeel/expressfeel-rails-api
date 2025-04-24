class PagesController < ApplicationController

	def phrasebook
		languages = [
			"MSA Arabic",
			"Egyptian Arabic",
			"Farsi",
			"French",
			"Italian",
			"Spanish",
			"Hebrew",
			"German",
			"Bengali",
			"Japanese",
			"Urdu"
		]

		@list= {}

		languages.each do |l|
			@list[l] = LessonKey.where(language: l)
		end
	end

	def landing
		BillingProduct.new.call
	  	BillingPlan.new.call
	end

	# 
	def rap
	end

end
