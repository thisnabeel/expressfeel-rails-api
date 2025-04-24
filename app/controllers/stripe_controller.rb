class StripeController < ApplicationController


	def success

		session =  Stripe::Checkout::Session.retrieve(params[:session_id])
		stripe_subscription = Stripe::Subscription.retrieve(session['subscription'])


		customer_id = session["customer"]
		email = Stripe::Customer.retrieve(session["customer"])["email"]

		puts "PUTTING SESSION !!!!!!!!!!!!!!"
		puts session
		# puts customer_id

		if User.find_by_stripe_id(customer_id).present?
			user = User.find_by_stripe_id(customer_id)
			email = user.email

		else
			username = User.make_unique(email.split("@")[0])
			random_id = 3.times.map { rand(0..9) }.join
			@display_pass = email.split("@")[0] + random_id

			user = User.create(
				stripe_id: customer_id, 
				email: email,
				username: username,
				password: @display_pass,
          		password_confirmation: @display_pass
			)


		end
		# puts "CUSTOMER: #{customer_id} = #{email}"

		deets =  {
			customer_id: customer_id,
			email: email,
			payment_status: session["payment_status"],
			amount: session["amount_total"].to_i * 0.10,
			stripe_subscription: stripe_subscription
		}


		# 
		# MAKE SUBSCRIPTION
		puts stripe_subscription

		if user.subscription.present? && 
			user.subscription.plan_id == stripe_subscription["id"] && 
			user.subscription.stripe_id == stripe_subscription["customer"]

			subscription = user.subscription
		else
		  subscription = ::Subscription.new(
		  	plan_id: stripe_subscription.plan.id,
			stripe_id: stripe_subscription.id,
			current_period_ends_at: Time.zone.at(stripe_subscription.current_period_end)
		  )

		  	puts "SUBSCRIBING MODEL!"
			user.update!(stripe_id: customer_id, subscription: subscription)
			puts "SUBSCRIBING MODEL MADE!"
		end

		# puts "DEETS:"
		# puts deets

		@user = user
		@subscription = user.subscription

		sign_in(:user, user)

	end

	def cancel
		user = User.find(params[:id])
		if user.fingerprint == params[:fingerprint]
			subscription = user.subscription
			Stripe::Subscription.delete(subscription.stripe_id)
			user.subscription.update(active: false)
			render json: user.subscription
		else
		end
	end

	def subscription
	end
end