Deface::Override.new(:virtual_path => "spree/checkout/_payment",
	                   :name => "checkout_payment_retailer_info",
	                   :insert_after => "[data-hook='buttons']",
	                   :partial => "spree/checkout/retailer_info",
	                   :disabled => false)