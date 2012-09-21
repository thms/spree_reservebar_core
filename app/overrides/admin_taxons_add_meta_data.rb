Deface::Override.new(:virtual_path => "spree/admin/taxons/_form",
	                   :name => "admin_taxon_form_retailers",
	                   :insert_bottom => "[data-hook='admin_inside_taxon_form']",
	                   :partial => "spree/admin/taxons/meta_tags",
	                   :disabled => false)
