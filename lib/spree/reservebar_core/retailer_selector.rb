module Spree
  module ReservebarCore
    class RetailerSelector
  
      # Selects a retailer for the supplied order
      # Initial algorithm for testing: pick where state matches or first
      # assumptions are this: all retailers will be able to fulfill any order that ships to their state, 
      # so we only need to find the one that is on the stat with the same shipment address.
      # Exceptions: If we do not have a retailer in the ship-to stat, we have to reject the order.
      def self.select(order)
        state_id = order.ship_address.state_id
        retailer = Spree::Retailer.joins(:physical_address).where('spree_addresses.state_id' => state_id).first || false
        retailer
      end
  
      # check wether we can ship to the selectd state
      # used early in the process to check if we can accept an order that ships to a state
      def self.can_ship_to_state?(state_id)
        Spree::Retailer.joins(:physical_address).where('spree_addresses.state_id' => state_id).count > 0
      end
    end
  end
end
