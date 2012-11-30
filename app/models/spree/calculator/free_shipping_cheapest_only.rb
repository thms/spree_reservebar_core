# Provides free shipping but only on the cheapest shipping method
module Spree
  class Calculator::FreeShippingCheapestOnly < Calculator
    def self.description
      I18n.t(:free_shipping_cheapest_only)
    end

    def compute(object)
      if object.is_a?(Array)
        return if object.empty?
        order = object.first.order
      else
        order = object
      end
      # Test if the shipping method selected on the order is the cheapest, if so deduct the shipping fees, otherwise not.
      if object.rate_hash.first[:shipping_method].id == object.shipping_method_id
        order.ship_total
      else
        0.0
      end
    end
  end
end
