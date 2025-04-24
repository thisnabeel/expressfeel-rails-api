class BillingCustomer < ApplicationRecord
  belongs_to :user, { required: false }
  has_many :billing_subscriptions # Ignore this for now, we'll be adding this later

  include CreateStripeBillingCustomer

end