Spree::TaxRate.class_eval do

	def to_string
		"#{zone.name} #{tax_category.name} #{amount} #{calculator.to_s}"
	end
	
	# Override the whole calculation when tax cloud is used
  # Creates necessary tax adjustments for the order.
  # When using tax cloud, the tax rate is not known until we get the tax amnount from tax could
  # But we need to be able to display the tax rate on the UI, so we first need to retrieve the tax rate for the 
  # order and then use that for the label and the actual calculation
  if Spree::Config[:use_taxcloud]
    def adjust(order)
      if self.calculator.class.name == "Spree::Calculator::TaxCloudCalculator"
        if order.retailer
          taxcloud_rate = TaxCloud::Rate.lookup(order.retailer.physical_address, order.ship_address)
        else
          taxcloud_rate = 0
        end
        label = "#{tax_category.name} #{taxcloud_rate * 100}%"
      else
        label = "#{tax_category.name} #{amount * 100}%"
      end
      
      if self.included_in_price
        if Zone.default_tax.contains? order.tax_zone
          order.line_items.each { |line_item| create_adjustment(label, line_item, line_item) }
        else
          amount = -1 * calculator.compute(order)
          label = I18n.t(:refund) + label
          order.adjustments.create(:amount => amount,
                                   :source => order,
                                   :originator => self,
                                   :locked => true,
                                   :label => label)
        end
      else
        create_adjustment(label, order, order)
      end
    
#      amount = self.calculator.compute(order)
#      return if amount == 0 
#      order.adjustments.create(:amount => amount,
#                                :source => order,
#                                :originator => self,
#                                :label => label,
#                                :mandatory => false)
    end
  end

end
