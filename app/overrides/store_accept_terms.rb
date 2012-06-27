Deface::Override.new(:virtual_path => "spree/checkout/_payment",
	                   :name => "accept_terms_and_conditions",
	                   :insert_after => "#payment",
	                   :partial => "spree/checkout/agree_to_terms",
	                   :disabled => false)
