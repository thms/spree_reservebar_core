Deface::Override.new(:virtual_path => "spree/products/show",
	                   :name => "store_product_seo_text",
	                   :insert_after => "[data-hook='product_recommendations']",
	                   :partial => "spree/products/seo_text",
	                   :sequence => 200, #force after product recommendations
	                   :disabled => false)
