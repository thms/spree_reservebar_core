Deface::Override.new(:virtual_path => "spree/products/_cart_form",
	                   :name => "store_product_replace_variant_selector",
	                   :replace => "#product-variants",
	                   :partial => "spree/products/variant_selector",
	                   :disabled => false)
