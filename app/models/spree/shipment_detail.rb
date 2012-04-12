class Spree::ShipmentDetail < ActiveRecord::Base
  
  # Use tokenized permissions to allow access from the jZebra applet
  token_resource
  belongs_to :shipment
  
end
