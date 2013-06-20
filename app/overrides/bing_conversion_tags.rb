# Insert on order summary page 
Deface::Override.new(:virtual_path => "spree/orders/show",
	                   :name => "bing_conversion",
	                   :insert_before => "#order",
	                   :partial => "spree/bing_tags/conversion",
	                   :disabled => false)
