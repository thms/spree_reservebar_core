Spree::PaymentMethod.class_eval do

  #attr_accessible :name, :description, :environment, :display_on, :active, :type
  
	def name_with_type
		"#{type}: #{name}"
	end

end
