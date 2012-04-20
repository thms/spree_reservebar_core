# Add print fedex test label link to each shipping method
Deface::Override.new(:virtual_path => "spree/admin/shipping_methods/index",
	                   :name => "shipment_make_ship_request",
	                   :insert_top => "[data-hook='admin_shipping_methods_index_row_actions']",
	                   :partial => "spree/admin/hooks/shipping_method_test_label",
	                   :disabled => false)
	                   
# Added zebra printer dialog to shipping method page
Deface::Override.new(:virtual_path => "spree/admin/shipping_methods/index",
	                   :name => "jzebra_dialog",
	                   :insert_top => "[data-hook='admin_shipping_methods_index_header_actions']",
	                   :partial => "spree/admin/hooks/jzebra_dialog",
	                   :disabled => false)
