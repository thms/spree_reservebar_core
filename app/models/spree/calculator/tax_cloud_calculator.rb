# Calculates tax based on the line item total + adjustments due to promotions + shipping cost + gift packaging
# TODO: should include excise tax somehow

module Spree
  class Calculator::TaxCloudCalculator < Calculator
    def self.description
      I18n.t(:tax_cloud_description)
    end

    def compute(computable)
      case computable
        when Spree::Order
          compute_order(computable)
        when Spree::LineItem
          compute_line_item(computable)
      end
    end


    private

      # Returns the attached tax rate, which has an amount, but we don't use that amount, we calculate via taxcloud below
      def rate
        rate = self.calculable
      end


      def compute_order(order)
        
        taxcloud_rate = TaxCloud::Rate.lookup(order.retailer.physical_address, order.ship_address)
        # Line item total
        matched_line_items = order.line_items.select do |line_item|
          line_item.product.tax_category == rate.tax_category
        end
        line_items_total = matched_line_items.sum(&:total)
        
        matched_adjustments = order.adjustments.eligible.select do |adjustment|
          adjustment.originator_type != 'Spree::TaxRate'
        end
        adjustments_total = matched_adjustments.sum(&:amount)

        round_to_two_places((line_items_total + adjustments_total + order.gift_packaging_total) * taxcloud_rate)
      end

      def compute_line_item(line_item, taxcloud_rate)
        if line_item.product.tax_category == rate.tax_category
          deduced_total_by_rate(line_item.total, rate)
        else
          0
        end
      end

      def round_to_two_places(amount)
        BigDecimal.new(amount.to_s).round(2, BigDecimal::ROUND_HALF_UP)
      end
      
      def deduced_total_by_rate(total, rate)
        round_to_two_places(total - ( total / (1 + rate.amount) ) )
      end

  end
end
