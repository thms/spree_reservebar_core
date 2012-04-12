# Add print fedex label link to each shipment
Deface::Override.new(:virtual_path => "spree/admin/shipments/index",
	                   :name => "shipment_make_ship_request",
	                   :insert_top => "[data-hook='admin_shipments_index_row_actions']",
	                   :partial => "spree/admin/hooks/shipment_make_ship_request",
	                   :disabled => false)
	                   
# Added zebra printer dialog to shipment page
Deface::Override.new(:virtual_path => "spree/admin/shipments/index",
	                   :name => "jzebra_dialog",
	                   :insert_top => "[data-hook='admin_shipments_index_header_actions']",
	                   :partial => "spree/admin/hooks/jzebra_dialog",
	                   :disabled => false)
