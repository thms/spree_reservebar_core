Deface::Override.new(:virtual_path => "spree/layouts/admin",
	                   :name => "best_in_place",
	                   :insert_bottom => "[data-hook='admin_footer_scripts']",
	                   :partial => "spree/admin/hooks/best_in_place_footer",
	                   :disabled => false)
