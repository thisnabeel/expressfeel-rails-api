class BillingPlan < ApplicationRecord
  belongs_to :billing_product
  has_many :billing_subscriptions # Ignore this for now, we'll be adding this later

  include SynchronizeBillingPlans

  def subscribe(user)
  	 customer = user.stripeid
  	 plan = self.stripeid

  	 subscription = Stripe::Subscription.create(
	  customer: customer,
	  items: [
	    {
	      plan: plan,
	    },
	  ],
	  expand: ['latest_invoice.payment_intent'],
	)

  	 puts subscription
  	 #  :billing_plan_id     # The BillingPlan that the BillingSubscription belongs to
     #  :billing_customer_id # The BillingCustomer that the BillingSubscription belongs to

     #  :stripeid		   # To map to the Subscription in Stripe
     #  :status			   # The status of the Stripe subscription (trialing, active, etc.)

     #  :current_period_end  # When the current subscription period will lapse
     #  :cancel_at		   # If set to cancel, when the cancellation will occur

  end

end