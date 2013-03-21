module Spree
  class Calculator::Florida < Calculator
    # Residential ship address
    preference :res_one_bottle_0_5lbs, :decimal, :default => 0
    preference :res_one_bottle_5_10lbs, :decimal, :default => 0
    preference :res_two_bottles_0_10lbs, :decimal, :default => 0
    preference :res_any_bottles_10_40lbs, :decimal, :default => 0
    preference :res_any_bottles_40_45lbs, :decimal, :default => 0

    # Business / commercial ship address
    preference :biz_one_bottle_0_5lbs, :decimal, :default => 0
    preference :biz_one_bottle_5_10lbs, :decimal, :default => 0
    preference :biz_two_bottles_0_10lbs, :decimal, :default => 0
    preference :biz_any_bottles_10_40lbs, :decimal, :default => 0
    preference :biz_any_bottles_40_45lbs, :decimal, :default => 0

    def self.description
      I18n.t(:florida_special)
    end

    # Object here should really only be an order or a shipment
    def compute(object)
      return unless object.present? and object.line_items.present?
      number_of_bottles = object.number_of_bottles
      if object.is_a?(Spree::Order)
        business = object.ship_address.is_business?
      else
        business = object.order.ship_address.is_business?
      end
      
      # Calculate the weight:
      multiplier = Spree::ActiveShipping::Config[:unit_multiplier]
      weight = object.line_items.inject(0) do |weight, line_item|
        weight + (line_item.variant.weight ? (line_item.quantity * line_item.variant.weight * multiplier) : Spree::ActiveShipping::Config[:default_weight])
      end
      # add the gift packaging weight - if any
      gift_packaging_weight = object.line_items.inject(0) do |gift_packaging_weight, line_item|
        gift_packaging_weight + (line_item.gift_package ? (line_item.quantity * line_item.gift_package.weight * multiplier) : 0.0)
      end
      # Caclulate weight of packaging
      package_weight = Spree::Calculator::ActiveShipping::PackageWeight.for(object)
      
      # Round up the weight to the nearest lbs, like Fedex does in their calculations. Weight is in lbs not in oz - different form other places where this is used.
      total_weight = ((weight + gift_packaging_weight + package_weight) / multiplier).ceil
      
      if business
        if number_of_bottles == 1 && total_weight <= 5
          value = preferred_biz_one_bottle_0_5lbs
        elsif number_of_bottles == 1 && total_weight <= 10
          value = preferred_biz_one_bottle_5_10lbs
        elsif number_of_bottles == 2 && total_weight <= 10
          value = preferred_biz_two_bottles_0_10lbs
        elsif total_weight <= 40 
          value = preferred_biz_any_bottles_10_40lbs
        else
          value = preferred_biz_any_bottles_40_45lbs
        end
      else
        if number_of_bottles == 1 && total_weight <= 5
          value = preferred_res_one_bottle_0_5lbs
        elsif number_of_bottles == 1 && total_weight <= 10
          value = preferred_res_one_bottle_5_10lbs
        elsif number_of_bottles == 2 && total_weight <= 10
          value = preferred_res_two_bottles_0_10lbs
        elsif total_weight <= 40 
          value = preferred_res_any_bottles_10_40lbs
        else
          value = preferred_res_any_bottles_40_45lbs
        end
      end
      (value * 100).round.to_f / 100
    end
  end
end
