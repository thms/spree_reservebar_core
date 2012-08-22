Deface::Override.new(:virtual_path => "spree/products/_cart_form",
	                   :name => "store_product_remove_add_to_cart_for_non_shipping",
	                   :replace => ".add-to-cart",
	                   :partial => "spree/products/add_to_cart",
	                   :disabled => false)
