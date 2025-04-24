module SynchronizeBillingProducts
  def call
    # First, we gather our existing products
    existing_products_by_stripeid = BillingProduct.all.each_with_object({}) do |product, acc|
      acc[product.stripeid] = product
    end

    # We're also going to keep track of the products we confirm exist on Stripe's end
    confirmed_existing_stripeids = []

    # Fetch all of our active products from Stripe
    Stripe::Product.list({ active: true })["data"].each do |product|
      puts "Product: #{product}"
      # If we are already aware of the product. let's just update the non-static fields on our end
      if existing_products_by_stripeid[product["id"]].present?
        existing_products_by_stripeid[product["id"]].update!({ stripe_product_name: product["name"] })
      # If we're not already aware of the product, let's create it on our end
      else
        BillingProduct.create!({
          stripeid: product["id"],
          stripe_product_name: product["name"],
        })
      end

      confirmed_existing_stripeids << product["id"]
    end

    # Lastly, delete any products on our end that no longer exist (or are not active) on Stripe
    BillingProduct.where.not({ stripeid: confirmed_existing_stripeids }).destroy_all

    nil
  end
end