Spree::Shipment.class_eval do
  
  # Shipment detail stores the ship response from Fedex, including the label, price, etc.
  has_one :shipment_detail
  
end