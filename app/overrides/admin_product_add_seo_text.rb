Deface::Override.new(:virtual_path => "spree/admin/products/_form",
	                   :name => "admin_products_seo_text",
	                   #:insert_after => "code[erb-loud]:contains('field_container :description')",
	                   :insert_bottom => "[data-hook='admin_product_form_left']",
	                   :partial => "spree/admin/products/seo_text",
	                   :disabled => false)
