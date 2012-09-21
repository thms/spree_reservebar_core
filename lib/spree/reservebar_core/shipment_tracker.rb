module Spree
  module ReservebarCore

    # Purpose: runs as a regualr background job to get tracking information for all outstanding packages
    # and update shipment state.
    # Shipment is extended to send email notifications on shipment state changes
    class ShipmentTracker
      
      def self.get_all_fedex_events
        Spree::Retailer.active.each do |retailer|
          ShipmentTracker.get_fedex_events_for_retailer(retailer)
        end
      end
      
      # get all shipment events for outstanding shipments per retailer (they have have their own shipping config)
      # TODO: Save th events to database, so the customer an see them without leaving the site.
      def self.get_fedex_events_for_retailer(retailer)
        fedex = ActiveMerchant::Shipping::FedEx.new(retailer.shipping_config)
        retailer.orders.where(:shipment_state => ['pending', 'ready', 'shipped']).each do |order|
          order.shipments.each do |shipment|
            begin
              tracking_info = fedex.find_tracking_info(shipment.tracking)
              shipment_state = tracking_info.events.last.name
              case tracking_info.events.last.name
              when "Picked up"  new_state = "shipped"
              when "Scanned"   new_state = "shipped"
              when "Departed"   new_state = "shipped"
              when "Arrived"   new_state = "shipped"
              when "Scanned"   new_state = "shipped"
              when "Delivered"  new_state = "delivered"
              end
              if shipment.state == 'shipped' && new_state == 'delivered' 
                shipment.deliver!
              elsif shipment.state == 'ready' && new_state == 'delivered'
                shipment.ship!
                shipment.deliver!
              elsif shipment.state == 'ready'
                shipment.ship!
              end
            rescue # something went wrong, no update to shipment
            end
          end
        end

        

    end
  end
end