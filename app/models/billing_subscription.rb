class BillingSubscription < ApplicationRecord
  belongs_to :billing_plan
  belongs_to :billing_customer

  def subscribe

  	#  :billing_plan_id     # The BillingPlan that the BillingSubscription belongs to
    #  :billing_customer_id # The BillingCustomer that the BillingSubscription belongs to

    #  :stripeid		   # To map to the Subscription in Stripe
    #  :status			   # The status of the Stripe subscription (trialing, active, etc.)

    #  :current_period_end  # When the current subscription period will lapse
    #  :cancel_at		   # If set to cancel, when the cancellation will occur

  end

end