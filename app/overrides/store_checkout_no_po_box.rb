Deface::Override.new(:virtual_path => "spree/checkout/_address",
	                   :name => "checkout_no_po_box",
	                   :insert_before => ".form-buttons",
	                   :partial => "spree/checkout/no_po_box",
	                   :disabled => false)
