class Stripe::GiftsController < ApplicationController
	 
	skip_before_action :verify_authenticity_token
	include ActionView::Helpers::TextHelper

	def new
		# ####################################################
		# This is used to make a new Gift checkout page pop-up    
		# ####################################################

		
		if Rails.env.production?  #=> true  
			puts "PRODUCTION!!!"
			link = "http://www.yasbahoon.com"
		else
			puts "DEVELOPMENT!!!"
			link = "http://localhost:3000"
		end

		# This is used to populate the checkout session content    
		# ####################################################


		cost = params[:cost].to_i * 100
		giftee = User.find(params[:giftee_id])

		giftee_id = params[:giftee_id]
		gifter_id = params[:gifter_id] || nil
		m = params[:months].to_i
		
		if m == 1
			months = "#{m} Month"
		else
			months = "#{m} Months"
		end

		if user_signed_in?
			email = current_user.email
		else
			email = nil
		end
		session = Stripe::Checkout::Session.create(
		    payment_method_types: ['card'],
		    line_items: [{
		      price_data: {
		        currency: 'usd',
		        product_data: {
		          name: "#{months} Gift for @#{giftee.username}",
		        },
		        unit_amount: cost,
		      },
		      quantity: 1,
		    }],
		    mode: 'payment',
		    # For now leave these URLs as placeholder values.
		    #
		    # Later on in the guide, you'll create a real success page, but no need to
		    # do it yet.
		    success_url: "#{link}/@#{giftee.username}?session_id={CHECKOUT_SESSION_ID}&gifter_id=#{gifter_id}&giftee_id=#{giftee_id}&months=#{m}",
		    cancel_url: "#{link}",
		    customer_email: email
		)

		render status: 200, json: {
	    	session: session,
	  	}.to_json
	end

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end