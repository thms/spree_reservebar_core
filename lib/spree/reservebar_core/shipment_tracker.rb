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
      # TODO: Update order state, when fully shipped. -- no need, it is part of the order update_shipment status anyway
      # TODO: retailers do not always click the order is ready for pick up button, which prevents the display state 
      #   from being correct, so we'll set order.packed_at to an hour ago if it is nil on the first transition.
      def self.get_fedex_events_for_retailer(retailer)
        fedex = ActiveMerchant::Shipping::FedEx.new(retailer.shipping_config)
        retailer.orders.where(:shipment_state => ['pending', 'ready', 'shipped']).each do |order|
          order.shipments.each do |shipment|
            begin
              tracking_info = fedex.find_tracking_info(shipment.tracking)
              # update shipment detail
              # Issues with UTF8 characters in the shipment events!
              #shipment.shipment_detail.update_attribute_without_callbacks(:ship_events, Marshal.dump(tracking_info.shipment_events))
              shipment_state = tracking_info.shipment_events.last.name
              new_state = ''
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
                shipment.order.update_attribute_without_callbacks(:packed_at, Time.now - 1.hour) if shipment.order.packed_at == nil
                shipment.deliver!
              elsif shipment.state == 'ready' && new_state == 'delivered'
                shipment.order.update_attribute_without_callbacks(:packed_at, Time.now - 1.hour) if shipment.order.packed_at == nil
                shipment.ship!
                shipment.deliver!
              elsif shipment.state == 'ready'
                shipment.order.update_attribute_without_callbacks(:packed_at, Time.now - 1.hour) if shipment.order.packed_at == nil
                shipment.ship!
              end
              
            rescue Exception => e # something went wrong, no update to shipment will happen
              puts e.message
            end
          end
        end
      end

        

    end
  end
end