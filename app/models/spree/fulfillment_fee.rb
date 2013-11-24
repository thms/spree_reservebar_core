# This class is used to allow the caclucation of adjustables for the fulfillment fee.
# THe adjustable concept requires an instance of an object to be able to update the adjustment
# This essentially a dummy object that onyl gets instantiated once. THe actual values are stred with the retailers and 
# product costs, to make the admin portion simpler.

class Spree::FulfillmentFee < ActiveRecord::Base
  
  # calculable is the order, the order
  def update_adjustment(adjustment, calculable)
    adjustment.update_attribute_without_callbacks(:amount, calculable.fulfillment_fee)
  end
  
end
