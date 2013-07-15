Spree::PaymentMethod.class_eval do

  ##attr_accessible :name, :description, :environment, :display_on, :active, :type, :deleted_at, :preferred_server
  ## TODO: this seems to not be sufficient, potentially need the same or similar on the gateway class
  
	def name_with_type
		"#{type}: #{name}"
	end

end
