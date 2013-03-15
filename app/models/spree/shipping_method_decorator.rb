Spree::ShippingMethod.class_eval do
  
  # Enable shipping methods for retailers
  has_and_belongs_to_many :retailers, :join_table => :spree_retailers_shipping_methods
  
  
  # Override here, to make this depend on the shipping methods enabled for a given retailer.
  def available_to_order?(order, display_on=nil)
    availability_check = available?(order,display_on)
    zone_check = zone && zone.include?(order.ship_address)
    category_check = category_match?(order)
    retailer_check = available_to_retailer?(order.retailer)
    availability_check && zone_check && category_check && retailer_check
  end
  
  # Test if the shipping method has been enabled for this retailer
  # This seems to be called sometimes before the the ship address is saved and th retailer is assigned
  def available_to_retailer?(retailer)
    if retailer
      self.retailer_ids.include?(retailer.id)
    else
      true
    end
  end
  
  def carrier_name
    begin
      self.calculator.carrier_name
    rescue
      "None"
    end
  end
  
end