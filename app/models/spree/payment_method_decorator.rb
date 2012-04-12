Spree::PaymentMethod.class_eval do

	def name_with_type
		"#{type}: #{name}"
	end

end
