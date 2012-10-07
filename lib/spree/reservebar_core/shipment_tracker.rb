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
      # TODO: Save the events to database, so the customer can see them without leaving the site.
      # TODO: Update order state, when fully shipped. -- no need, it is part of the order update_shipment status
      def self.get_fedex_events_for_retailer(retailer)
        fedex = ActiveMerchant::Shipping::FedEx.new(retailer.shipping_config)
        retailer.orders.where(:shipment_state => ['pending', 'ready', 'shipped']).each do |order|
          order.shipments.each do |shipment|
            begin
              tracking_info = fedex.find_tracking_info(shipment.tracking)
              # update shipment detail
              shipment.shipment_detail.update_attribute(:ship_events, Marshal.dump(tracking_info.shipment_events))
              shipment_state = tracking_info.shipment_events.last.name
              case 
                 when shipment_state.include?("Picked up")
                   new_state = "shipped"
                 when shipment_state.include?("Scanned")   
                   new_state = "shipped"
                 when shipment_state.include?("Departed")   
                   new_state = "shipped"
                 when shipment_state.include?("Arrived" )  
                   new_state = "shipped"
                 when shipment_state.include?("Scanned")   
                   new_state = "shipped"
                 when shipment_state.include?("Delivered")  
                   new_state = "delivered"
               end
               if shipment.state == 'shipped' && new_state == 'delivered' 
                shipment.deliver!
              elsif shipment.state == 'ready' && new_state == 'delivered'
                shipment.ship!
                shipment.deliver!
              elsif shipment.state == 'ready'
                shipment.ship!
              end
              
            rescue # something went wrong, no update to shipment will happen
            end
          end
        end
      end

        

    end
  end
end