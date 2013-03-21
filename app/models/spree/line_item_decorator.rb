Spree::LineItem.class_eval do
  
  # calculate amount for corporate (TODO: this may need to be revised for reporting to be the same as the profit)
  def margin_for_site
    product_costs = variant.product_costs.where(:retailer_id => order.retailer_id)
    (product_costs.empty? ? price : (price - product_costs.first.cost_price)) * quantity
  end
  
  # Handle case where the product cost for the retailer has not been defined yet
  def product_cost_for_retailer
    product_costs = variant.product_costs.where(:retailer_id => order.retailer_id)
    product_costs.empty? ? 0 : product_costs.first.cost_price * quantity
  end
  
  # Calulate the profit for a given line item based on the retailer's product costs
  # For routing purposes, we assume that the profit is zero if the product cost is not filled in.
  def profit(retailer)
    product_costs = variant.product_costs.where(:retailer_id => retailer.id)
    product_costs.empty? ? 0 : (price - product_costs.first.cost_price) * quantity
    
  end
  
end