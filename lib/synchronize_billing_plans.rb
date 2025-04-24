module SynchronizeBillingPlans
  def call
    # First, we gather our existing plans
    existing_plans_by_stripeid = BillingPlan.all.each_with_object({}) do |plan, acc|
      acc[plan.stripeid] = plan
    end

    # We're also going to keep track of the plans we confirm exist on Stripe's end
    confirmed_existing_stripeids = []

    # Fetch all of our active plans from Stripe
    Stripe::Plan.list({ active: true })["data"]
      .each do |plan|
        # If we are already aware of the plan, let's just update the non-static fields on our end
        if existing_plans_by_stripeid[plan["id"]].present?
          existing_plans_by_stripeid[plan["id"]].update!({
            stripe_plan_name: plan["nickname"],
            amount: plan["amount"],
          })
        # If we're not already aware of the plan, let's create it on our end
        else
          BillingPlan.create!({
            billing_product: BillingProduct.find_by({ stripeid: plan["product"] }),
            stripeid: plan["id"],
            stripe_plan_name: plan["nickname"],
            amount: plan["amount"],
          })
        end

        confirmed_existing_stripeids << plan["id"]
      end

    # Lastly, delete any plans on our end that no longer exist (or are not active) on Stripe
    BillingPlan.where.not({ stripeid: confirmed_existing_stripeids }).destroy_all

    nil
  end
end