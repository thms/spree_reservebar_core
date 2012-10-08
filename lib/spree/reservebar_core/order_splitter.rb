module Spree
  module ReservebarCore

    # The purpose of this class is to take an existing order than cannot be fulfilled by a single retailer
    # and figure out a way to split this order such that it can be fulfilled by several retailers
    # Usage: first exclude all shipping categories that we cannot ship to the state, let the user remove these items.
    # Then find a subset of categories that a single retailer can ship, and let the user remove the other items
    # Basic strategy: pick order apart by shipping category
    # Build array of shipping catagories for the order
    # POssible outcomes: (x & y can be sets, start with single categories first)
    #  x & y cannot be shipped together
    #  x can be shipped, but y cannot
    class OrderSplitter
      
      def self.find_shippable_categories(order)
        # get all shipping categories contained in the order:
        shipping_categories = order.shipping_categories
        
        # for each catgory contained in the order, check if we can ship it to the state at all (with one or many retailers does not matter)
        state = order.ship_address.state
        shippable_categories = []
        unshippable_categories = [] # categories that we cannot under any circumstances ship to the state
        shipping_categories.each do |shipping_category_id|
          query = "ships_#{Spree::ShippingCategory.find(shipping_category_id).name.downcase.gsub(' ','_')}_to like :state"
          if Spree::Retailer.active.where(query,  :state => "%#{state.abbr}%").count > 0
            shippable_categories << shipping_category_id
          else
            unshippable_categories << shipping_category_id
          end
        end
        {:shippable => shippable_categories, :unshippable =>  unshippable_categories}
      end
      
      
      # take shippable categories and see if some cannot be shipped together (by the same retailer)
      # this method should only ever be called if there is at least one category that cannot be shipped with the others
      # probably sufficient to find one category that does not work with one other together
      # e.g. even if the order has three categories, it might be enough to say cat1 cannot be shipped with cat 2, irrespective of cat3
      # strategy: simple search: remove one and see if we can find a retailer for remaining categories, stop search if one found
      def self.one_level_search(shipping_category_ids, state)
        found_solution = false
        # remove each catogory and try to find a retailer for the remaining categories
        shipping_category_ids.each do |shipping_category_id|
          remaining_categories = shipping_category_ids - [shipping_category_id]
          query = []
          remaining_categories.each do |remaining_category_id|
            query << "ships_#{Spree::ShippingCategory.find(remaining_category_id).name.downcase.gsub(' ','_')}_to like :state"
          end
          retailers = Spree::Retailer.active.where(query.join(' and '),  :state => "%#{state.abbr}%")
          if retailers.count > 0
            found_solution = true
            return {:shippable => remaining_categories, :unshippable => [shipping_category_id]}
          end
        end
        # If we cannt find a solution return false
        return false
      end
      
      # if the simple search does not find any possible combination, we just remove another category and run the simple serach on the remaining 
      # categories....
      def self.full_search(shipping_category_ids, state)
        # try one level down:
        result = OrderSplitter.one_level_search(shipping_category_ids, state)
        return result if result
        
        # try to remove one category and search one level down
        shipping_category_ids.each do |shipping_category_id|
          remaining_shipping_categories = shipping_category_ids - [shipping_category_id]
          result = OrderSplitter.one_level_search(remaining_shipping_categories, state)
          return result if result
        end
        return false
      end
      
    end


    # There should also be a class that handles messaging to the user
    class OrderMessaging
    end

  end
end
