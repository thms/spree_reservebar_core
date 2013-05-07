Deface::Override.new(:virtual_path => "spree/admin/products/_form",
	                   :name => "admin_products_shipping_surcharge",
	                   :insert_bottom => "[data-hook='admin_product_form_right']",
	                   :partial => "spree/admin/products/shipping_surcharge",
	                   :disabled => false)
