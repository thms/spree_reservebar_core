# Calculates the fulfillment fee for an order
# The fee is taxable and depends on the retailer the sku and the quantity for each item
# It is aggregated into one adjustment for the entire order, so that it is asy to show on the
# various views.
module Spree
  class Calculator::FulfillmentFee < Calculator

    def self.description
      I18n.t(:fulfillment_fee)
    end

    # This calculates on the order object only, not on line items.
    # The calculation of the fee is done on the order object.
    def compute(object)
      return unless object.present? and object.line_items.present?
      value = object.fulfillment_fee
      value = (value * 100).round.to_f / 100
     end
  end
end
