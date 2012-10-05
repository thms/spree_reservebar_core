Deface::Override.new(:virtual_path => "spree/admin/products/_form",
	                   :name => "admin_products_legal_terms",
	                   #:insert_after => "code[erb-loud]:contains('field_container :description')",
	                   :insert_bottom => "[data-hook='admin_product_form_left']",
	                   :partial => "spree/admin/products/legal_terms",
	                   :disabled => false)
