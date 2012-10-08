Deface::Override.new(:virtual_path => "spree/shared/_order_details",
	                   :name => "user_account_ship_events",
	                   :insert_before => "[data-hook='order_details']",
	                   :partial => "spree/orders/ship_events",
	                   :disabled => false)
