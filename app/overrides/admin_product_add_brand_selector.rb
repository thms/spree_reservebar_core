Deface::Override.new(:virtual_path => "spree/admin/products/_form",
	                   :name => "admin_products_brand_selector",
	                   :insert_bottom => "[data-hook='admin_product_form_right']",
	                   :partial => "spree/admin/products/brand_selector",
	                   :disabled => false)
