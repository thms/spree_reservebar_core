# Takes smaller amount of percentage of item total and cap
module Spree
  class Calculator::PercentItemTotalWithCap < Calculator
    preference :percent, :decimal, :default => 0
    preference :cap, :decimal, :default => 0

    def self.description
      I18n.t(:flat_percent_with_cap)
    end

    def compute(object)
      return unless object.present? and object.line_items.present?
      item_total = object.line_items.map(&:amount).sum
      value = item_total * BigDecimal(self.preferred_percent.to_s) / 100.0
      value = (value * 100).round.to_f / 100
      if value > self.preferred_cap
        return self.preferred_cap
      else
        return value
      end
    end
  end
end
