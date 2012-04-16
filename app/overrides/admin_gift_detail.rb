Deface::Override.new(:virtual_path => "spree/admin/orders/show",
	                   :name => "admin_gift_detail",
	                   :insert_before => "[data-hook='admin_order_show_details']",
	                   :partial => "spree/admin/hooks/gift_detail",
	                   :disabled => false)
