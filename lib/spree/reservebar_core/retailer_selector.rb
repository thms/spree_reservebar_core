
module Spree
  module ReservebarCore

    class RetailerSelector
      
      # Retailer in state gets picked if he can ship over retailer out of state that can also ship
      # Support convoluted messaging logic by searching combinations.
  
      # Selects a retailer for the supplied order
      # Initial algorithm for testing: pick where state matches or first
      # assumptions are this: all retailers will be able to fulfill any order that ships to their state, 
      # so we only need to find the one that is on the state with the same shipment address.
      # Exceptions: If we do not have a retailer in the ship-to state, we have to reject the order.
      def self.select(order)
        state = order.ship_address.state
        
        # if we can't ship anything to the state, so bail out early:
        raise Exceptions::NoRetailerShipsToStateError unless can_ship_to_state?(state)
        
        
        # Try and find a retailer that can ship all items to the state
        query = []
        order.shipping_categories.each do |shipping_category_id|
          query << "ships_#{Spree::ShippingCategory.find(shipping_category_id).name.downcase.gsub(' ','_')}_to like :state"
        end
        retailers = Spree::Retailer.active.where(query.join(' and '),  :state => "%#{state.abbr}%")
        # if we have more than one retailer that can ship to the state, pick the one that is located in the state, otherwise, just pick random
        if retailers.count > 1
          begin
            retailer = retailers.select {|r| r.physical_address.state == state}.first
          rescue
            retailer = retailers.sample
          end
        elsif retailers.count == 1
          retailer = retailers.first
        else
          retailer = nil
          #  raise no retailer found error 
          raise Exceptions::NoRetailerCanShipFullOrderError
        end
        
        # Now, if we do not have a retailer that can ship to the state, check if we can ship the partial order.
        # But this is only used for messaging to the user, retailer selection has completed, so we make that another class, function
        
        # Return the retailer if we have found one.
        retailer
      end
  
      # check whether we can ship anything at all to the selected state
      # can be used early in the process to check if we can accept an order that ships to a state
      # Not yet used at all
      def self.can_ship_to_state?(state)
        # early version, based on retailer's physical presence in the state:
        # Spree::Retailer.joins(:physical_address).where('spree_addresses.state_id' => state.id).count > 0
        # current version: based on Retailers ships_spirits_to, etc settings
        Spree::Retailer.active.where("ships_spirits_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_wine_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_champagne_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_beer_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_other_products_to like :state", :state => "%#{state.abbr}%").count > 0
      end
      
      # if we cannot ship the selected categories to the state, check what other categories (if any) we can ship there
      def self.find_shippable_category_names(state)
        names = []
        names << 'Wines' if Spree::Retailer.active.where("ships_wine_to like :state", :state => "%#{state.abbr}%").count > 0
        names << 'Spirits' if Spree::Retailer.active.where("ships_spirits_to like :state", :state => "%#{state.abbr}%").count > 0
        names << 'Champagne' if Spree::Retailer.active.where("ships_champagne_to like :state", :state => "%#{state.abbr}%").count > 0
        names << 'Beer' if Spree::Retailer.active.where("ships_beer_to like :state", :state => "%#{state.abbr}%").count > 0
        names.join(', ')
      end
      
      
    end
  end
end