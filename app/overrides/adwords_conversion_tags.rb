# Insert on order summary page 
Deface::Override.new(:virtual_path => "spree/orders/show",
	                   :name => "adwords_conversion",
	                   :insert_before => "#order",
	                   :partial => "spree/adwords_tags/conversion",
	                   :disabled => false)
