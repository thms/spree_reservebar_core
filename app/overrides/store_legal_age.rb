Deface::Override.new(:virtual_path => "spree/checkout/_address",
	                   :name => "is_legal_drinking_age",
	                   :insert_before => ".form-buttons",
	                   :partial => "spree/checkout/legal_age",
	                   :sequence => 200, # do this after the gift box
	                   :disabled => false)
