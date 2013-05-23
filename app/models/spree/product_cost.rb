module Spree
  # This class stores the product cost for each retailer
  # Reservebar uses this to determine the payout for each product for a given retailer
  # Total payout may include the shipping fees, depending on retailer
  class ProductCost < ActiveRecord::Base
    belongs_to :retailer
    belongs_to :variant
    
    
    def shipping_surcharge_is_not_zero
      where('shipping_surcharge_is_not_zero > 0')
    end
    
  end
end
