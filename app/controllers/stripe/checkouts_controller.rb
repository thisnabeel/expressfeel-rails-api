class Stripe::CheckoutsController < ApplicationController
	 
	skip_before_action :verify_authenticity_token

	def new

		# ####################################################
		# This is used to make a new checkout page pop-up    
		# ####################################################
		
		if Rails.env.production?  #=> true  
			puts "PRODUCTION!!!"
			link = "http://www.expressfeel.com"
		else
			puts "DEVELOPMENT!!!"
			link = "http://localhost:3000"
		end

		if user_signed_in?
			stripe_id = current_user.stripe_id
		end

		# This is used to populate the checkout session content    
		# ####################################################
		session = Stripe::Checkout::Session.create(
		    payment_method_types: ['card'],
		    subscription_data: {
				items: [{
			      plan: BillingPlan.first.stripeid,
			    }],
			},

			# These are the redirect links once complete    
			# ####################################################
		    success_url: "#{link}/success?session_id={CHECKOUT_SESSION_ID}",
		    cancel_url: "#{link}",
		    customer: stripe_id
		)

		render status: 200, json: {
	    	session: session,
	  	}.to_json
	end

	def webhook
	  sig_header = request.env['HTTP_STRIPE_SIGNATURE']

	  begin
	    event = Stripe::Webhook.construct_event(request.body.read, sig_header, "whsec_ZtRoC5SxqWQs4pshfbrKAcEjM8S8PNRV")
	  rescue JSON::ParserError
	    return head :bad_request
	  rescue Stripe::SignatureVerificationError
	    return head :bad_request
	  end

	  puts event
	  webhook_checkout_session_completed(event) if event['type'] == 'invoice.finalized'

	  head :ok
	end

	private 

		def build_subscription(stripe_subscription)
		    Subscription.new(plan_id: stripe_subscription.plan.id,
		                     stripe_id: stripe_subscription.id,
		                     current_period_ends_at: Time.zone.at(stripe_subscription.current_period_end))
		end

		def webhook_checkout_session_completed(event)
		  # puts event
		  puts "WEBHOOK THING HAPPENING NOW"
		  object = event['data']['object']
		  email = object["customer_email"]
		  puts "object['email']: #{object['customer_email']}"
		  customer = Stripe::Customer.retrieve(object['customer'])
		  puts "CUSTOMER: #{customer}"
		  puts "object['subscription']: #{object['subscription']}"
		  puts "Trying To retrieve"

		  stripe_subscription = Stripe::Subscription.retrieve(object['subscription'])
		  puts "SUBSCRIPTION!: #{stripe_subscription}"
		  
		  subscription = ::Subscription.new(
		  	plan_id: stripe_subscription.plan.id,
			stripe_id: stripe_subscription.id,
			current_period_ends_at: Time.zone.at(stripe_subscription.current_period_end)
			)

		  username = "placeholder_" + User.make_unique(email.split("@")[0])

		  user = User.find_by(email: email)

		  user.subscription.interrupt if user.subscription.present?
		  # 
		  puts "SUBSCRIBING MODEL!"
		  user.update!(stripe_id: customer.id, subscription: subscription)
		  puts "SUBSCRIBING MODEL MADE!"
		end
end