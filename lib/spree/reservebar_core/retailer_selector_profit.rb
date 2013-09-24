# Class that defines the retailer selector whtih county based assignments
module Spree
  module ReservebarCore

    class RetailerSelectorProfit
      
      # Base retailer selection on profits, and prefer in-state over out of state
      # uses scoring mechanism to simplify the code
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
        
        # Find all retailers that can ship all items to the state
        query = []
        order.shipping_categories.each do |shipping_category_id|
          query << "ships_#{Spree::ShippingCategory.find(shipping_category_id).name.downcase.gsub(' ','_')}_to like :state"
        end
        retailers = Spree::Retailer.active.where(query.join(' and '),  :state => "%#{state.abbr}%")
        
        # No retailer can ship all items to the state, bail out here
        if retailers.count == 0
          raise Exceptions::NoRetailerCanShipFullOrderError
        end
        
        # score county based routing rules - not very efficient, better to reject them outright rather than to calculate scores later on
        # county_scores = retailers.map {|retailer| {retailer.id => retailer.can_ship_to_county?(county) ? 1 : -10000 }}
        # reject all in-state retailers that cannot deliver to the county in question, this leaves all out of state retailers through, since they are supposed to be able to ship to all counties in another state
        retailers = retailers.reject {|retailer| !retailer.can_ship_to_county?(county, state)}
        
        # If we have no retailers after this step, ths can only be due to county rules based rejection
        if retailers.count == 0
          raise Exceptions::NoRetailerShipsToCountyError
        end
        
        # Score the different retailers to find the one to assign the order to
        if retailers.count > 1
          # score order profit
          profit_scores = retailers.map {|retailer| {retailer.id => order.profit(retailer)}}
          profit_scores = profit_scores.reduce Hash.new, :merge
        
          # score in-state vs out of state (to break a potential tie if two retailers can fulfil the order with equal profit)
          in_state_scores = retailers.map {|retailer| {retailer.id => order.ship_address.state_id == retailer.physical_address.state_id ? 50 : 0}}
          in_state_scores = in_state_scores.reduce Hash.new, :merge
        
          # score specifically routed products in the order
          if order.contains_routed_products?
            route_scores = retailers.map {|retailer| {retailer.id => retailer_route_score(retailer, order)}}
          else
            route_scores = retailers.map {|retailer| {retailer.id => 0}}
          end
          route_scores = route_scores.reduce Hash.new, :merge
        
          # Combine scores and eliminate all that have negative score:
          scores = profit_scores
          scores.merge!(in_state_scores) {|key, v1, v2| v1 + v2}
          scores.merge!(route_scores) {|key, v1, v2| v1 + v2}
        
          # Sort by highest score first so we only have one retailer left
          scores = scores.to_a
          scores.sort! {|a,b| b[1] <=> a[1]}
          retailer_id  = scores.first[0]
          retailer = (retailers.select {|r| r.id == retailer_id}).first
        else
          retailer = retailers.first
        end
              
        # Raise exception if we did not find a retailer
        if retailer == nil
          raise Exceptions::NoRetailerCanShipFullOrderError
        end
        
        # Return the retailer if we have found one.
        retailer
      end
      
      # Calculate a score for a retailer's routed products
      # If there are products in the order that are routed to the retailer: +1000
      # If there are products in the order that are routed away from the retailer: -10
      def self.retailer_route_score(retailer, order)
        score = 0
        # If there are products in the order that are routed to the retailer: +1000
        score = score + 1000 unless (retailer.routes.preferred.map(&:product_id) & order.products.map(&:id)).empty?
        score = score - 1000 unless (retailer.routes.last_resort.map(&:product_id) & order.products.map(&:id)).empty?
        score
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
