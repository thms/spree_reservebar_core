module Spree
  module ReservebarCore
    class RetailerSelector
  
      # Selects a retailer for the supplied order
      # Initial algorithm for testing: pick where state matches or first
      # assumptions are this: all retailers will be able to fulfill any order that ships to their state, 
      # so we only need to find the one that is on the stat with the same shipment address.
      # Exceptions: If we do not have a retailer in the ship-to state, we have to reject the order.
      def self.select(order)
        state = order.ship_address.state
        # if we can't ship to the state, bail out:
        return false unless can_ship_to_state(state)
        # if the order only has wine, use the super retailer, if he delivers to that state
        if order.has_only_wine?
          retailer = Spree::Retailer.active.where(:is_super_retailer => true)
          retailer = false unless retailer.ships_wine_to.include?(state.abbr)
        end
        # if the order has other items besides wine, or the super retailer does not ship to that state, try another retailer that ships to the state:
        unless retailer
          retailer =  Spree::Retailer.active.where("ships_spirits_to like :state", :state => "%#{state.abbr}%").first ||
                      Spree::Retailer.active.where("ships_wine_to like :state", :state => "%#{state.abbr}%").first || 
                      Spree::Retailer.active.where("ships_beer_to like :state", :state => "%#{state.abbr}%").first || 
                      Spree::Retailer.active.where("ships_beer_to like :state", :state => "%#{state.abbr}%").first ||
                      false
        end
        retailer
      end
  
      # check whether we can ship to the selected state
      # can be used early in the process to check if we can accept an order that ships to a state
      # Not yet used at all
      def self.can_ship_to_state?(state)
        # early version, based on retailer's physical presence in the state:
        # Spree::Retailer.joins(:physical_address).where('spree_addresses.state_id' => state.id).count > 0
        # current version: based on Retailers ships_spirits_to, etc settings
        Spree::Retailer.active.where("ships_spirits_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_wine_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_champagne_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_beer_to like :state", :state => "%#{state.abbr}%").count > 0 
      end
      
      
    end
  end
end