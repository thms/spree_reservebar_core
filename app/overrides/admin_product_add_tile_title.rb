Deface::Override.new(:virtual_path => "spree/admin/products/_form",
	                   :name => "admin_products_tile_title",
	                   :insert_before => "code[erb-loud]:contains('field_container :permalink')",
	                   :partial => "spree/admin/products/tile_title",
	                   :disabled => false)
