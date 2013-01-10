# A rule that triggers wen a user has X or more items
module Spree
  class Promotion::Rules::NumberOfItems < PromotionRule
    preference :number_of_items, :integer, :default => 1

    def eligible?(order, options = {})
      number_of_items = order.line_items.map(&:quantity).sum
      number_of_items >= preferred_number_of_items
    end
  end
end
