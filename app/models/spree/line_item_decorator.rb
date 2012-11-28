Spree::LineItem.class_eval do
  
  # calculate amount for corporate
  def margin_for_site
    product_costs = variant.product_costs.where(:retailer_id => order.retailer_id)
    (product_costs.empty? ? price : (price - product_costs.first.cost_price)) * quantity
  end
  
  # Handle case where the product cost for the retailer has not been defined yet
  def product_cost_for_retailer
    product_costs = variant.product_costs.where(:retailer_id => order.retailer_id)
    product_costs.empty? ? 0 : product_costs.first.cost_price * quantity
  end
  
end
