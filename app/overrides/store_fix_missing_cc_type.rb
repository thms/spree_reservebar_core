Deface::Override.new(:virtual_path => "spree/shared/_order_details",
	                   :name => "orders_fix_missing_cc_type",
	                   :replace => ".cc-type",
	                   :partial => "spree/orders/fix_missing_cc_type",
	                   :disabled => false)
