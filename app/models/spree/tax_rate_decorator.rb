Spree::TaxRate.class_eval do

	def to_string
		"#{zone.name} #{tax_category.name} #{amount} #{calculator.to_s}"
	end

end
