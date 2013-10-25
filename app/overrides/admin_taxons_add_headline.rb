Deface::Override.new(:virtual_path => "spree/admin/taxons/_form",
	                   :name => "admin_taxon_add_headline",
	                   :insert_before => "code[erb-loud]:contains('field_container :permalink_part')",
	                   :partial => "spree/admin/taxons/headline",
	                   :disabled => false)
