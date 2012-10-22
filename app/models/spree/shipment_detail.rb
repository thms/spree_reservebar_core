class Spree::ShipmentDetail < ActiveRecord::Base
  
  # Use tokenized permissions to allow access from the jZebra applet
  token_resource
  belongs_to :shipment
  
  # We get the shipevents as arrays and want to just get them in and out as arrays
  serialize :ship_events
  
end
