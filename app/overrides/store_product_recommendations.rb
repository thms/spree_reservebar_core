Deface::Override.new(:virtual_path => "spree/products/show",
	                   :name => "store_product_recommendations",
	                   :insert_after => "[data-hook='product_show']",
	                   :partial => "spree/hooks/product_recommendations",
	                   :disabled => false)

