# allows the user to take of a certain percentage and also gain free shipping
module Spree
  class Calculator::PercentItemTotalPlusFreeShipping < Calculator

    preference :percent, :decimal, :default => 0
    preference :cap, :decimal, :default => 0

    def self.description
      I18n.t(:percent_item_total_plus_free_shipping)
    end

    def compute(object)
      return unless object.present? and object.line_items.present?
      item_total = object.line_items.map(&:amount).sum
      value = item_total * BigDecimal(self.preferred_percent.to_s) / 100.0
      value = (value * 100).round.to_f / 100
      
      # pick lower of cap or percentage off
      if value > self.preferred_cap
        value = self.preferred_cap
      end
      
      # Test if the shipping method selected on the order is the cheapest, if so deduct the shipping fees, otherwise not.
      if object.rate_hash.first[:shipping_method].id == object.shipping_method_id
        value + object.ship_total
      else
        value
      end
    end
  end
end
