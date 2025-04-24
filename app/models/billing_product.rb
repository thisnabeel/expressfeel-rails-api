class BillingProduct < ApplicationRecord
  has_many :billing_plans # Ignore this for now, we'll be adding this later

  include SynchronizeBillingProducts
end