# Class that defines the retailer selector whtih county based assignments
module Spree
  module ReservebarCore

    class RetailerSelectorCounty
      
      # Retailer in state gets picked if he can ship over retailer out of state that can also ship
      # Selects a retailer for the supplied order
      # Initial algorithm for testing: pick where state matches or first
      # Exceptions: If we do not have a retailer in the ship-to state, we have to reject the order.
      def self.select(order)
        
        # Get the state of the shipping address
        state = order.ship_address.state
        
        # assign county or nil.
        # Current rule is that if county lookup failed we assign the default retailer, if we have one
        begin
          county = order.ship_address.county
        rescue
          county = nil
        end
    

        # if we can't ship anything to the state, bail out early:
        raise Exceptions::NoRetailerShipsToStateError unless can_ship_to_state?(state)
        
        # Try and find a retailer that can ship all items to the state
        query = []
        order.shipping_categories.each do |shipping_category_id|
          query << "ships_#{Spree::ShippingCategory.find(shipping_category_id).name.downcase.gsub(' ','_')}_to like :state"
        end
        retailers = Spree::Retailer.active.where(query.join(' and '),  :state => "%#{state.abbr}%")
        
        # if we have retailers in the state, check county based routing rules (if we have a county)
        if retailers.select {|r| r.physical_address.state == state}.count > 0 && county
          other_retailers_in_state = retailers.select {|r| r.physical_address.state == state && r.is_default == false}
          # If a non-default retailer can ship to the county, pick that one
          retailer = other_retailers_in_state.select {|r| r.county_ids.include?(county.id)}.first
          
          # If we did not find one, but there is a default retailer in the state, pick that one
          if retailer == nil 
            retailer = retailers.select {|r| r.physical_address.state == state && r.is_default == true}.first
          end
          
          # If we still do not have an in-state retailer, then the county is not covered by them, and routing stops. 
          if retailer == nil
            raise Exceptions::NoRetailerShipsToCountyError
          end
          
        else # We either do no have a county, or we do not have in-state retailers. 
          # If we do not have a county, but we have an in-state retailer that is the default for the state, assign to him
          # If we do not have in-state retailers, county routing does not apply, so pick one.
          # 
          # Reject if county is unkown and there is not default retailer in the state.
          if retailers.count > 1
            begin
              retailer = retailers.select {|r| (r.physical_address.state == state) && (r.is_default == true)}.first
            rescue
              retailer = retailers.select {|r| (r.physical_address.state != state)}.first
            end
          elsif retailers.count == 1
            retailer_candidate = retailers.first
            if retailer_candidate.physical_address.state == state && county
              retailer = retailer_candidate
            elsif retailer_candidate.physical_address.state == state && retailer_candidate.is_default
              retailer = retailer_candidate
            elsif retailer_candidate.physical_address.state == state
              retailer = retailer_candidate
            end
          else
            retailer = nil
            #  raise no retailer found error 
            raise Exceptions::NoRetailerCanShipFullOrderError
          end
        end
              
        # Return the retailer if we have found one.
        retailer
      end
  
      # check whether we can ship anything at all to the selected state
      # can be used early in the process to check if we can accept an order that ships to a state
      def self.can_ship_to_state?(state)
        # current version: based on Retailers ships_spirits_to, etc settings
        Spree::Retailer.active.where("ships_spirits_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_wine_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_champagne_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_beer_to like :state", :state => "%#{state.abbr}%").count > 0 ||
        Spree::Retailer.active.where("ships_other_products_to like :state", :state => "%#{state.abbr}%").count > 0
      end

      # check whether we can ship anything at all to the selected county, only applicable if the state has at least one in-state retailer
      # desired behaviour: break off search if in-state retailers could be assigned the order, but none ships to the selected county
      # We only get here if we can ship to the state, county shipping rules are after the state shipping rules
      # can be used early in the process to check if we can accept an order that ships to a county
      # If county is nil, we can ship by default (since that means that the shipping address does not have a  county)
      # Fundamentatlly flawed - do not use
      def self.can_ship_to_county?(county)
        # current version: based on Retailer's county assignment
        
        if county == nil
          # If the county for the address is nil, we can ship TODO: might need to change that logic such that we can only ship if the county is nil and we have a default retailer
          return true
        elsif Spree::Retailer.default_in_state(county.state)
          # if we have a default retailer for that state, we can ship
          return true
        elsif Spree::Retailer.active.joins(:counties).where(:spree_counties_retailers => {:county_id => county.id}).exists?
          return true
        else
          return false
        end
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
