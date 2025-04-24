class Subscription < ActiveRecord::Base
	
	belongs_to :user

	def interrupt
	  begin
	  	Stripe::Subscription.delete(stripe_id)
	  	self.active = false
	  	save
	  rescue StandardError => e
	  	puts e
	  	self.destroy
	  end
	end

	def gift(duration)
		time = self.current_period_ends_at
		# New Time = When it was ending, plus the selected gift months
		new_time = time + duration.month

		puts "Was ending at: #{time}"
		puts "Will now end at: #{new_time}"

		# Stripe::Subscription.update(
		#   self.stripe_id,
		#   {
		#     pause_collection: {
		#       behavior: 'keep_as_draft',
		#       resumes_at: (new_time + 1.day).to_i,
		#     },
		#   }
		# )

		Stripe::Subscription.update(
		  self.stripe_id,
		  {
		    trial_end: new_time.to_i,
		    proration_behavior: 'none',
		  }
		)


		self.update(current_period_ends_at: new_time)


	end

end