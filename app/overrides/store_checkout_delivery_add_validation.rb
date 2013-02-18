Deface::Override.new(:virtual_path => "spree/checkout/_delivery",
	                   :name => "checkout_delivery_method_validation",
	                   :insert_after => "#shipping_method",
	                   :partial => "spree/checkout/delivery_method_validation",
	                   :disabled => false)