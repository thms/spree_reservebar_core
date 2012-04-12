Deface::Override.new(:virtual_path => "spree/admin/users/_form",
	                   :name => "admin_user_form_retailers",
	                   :insert_after => "[data-hook='admin_user_form_roles']",
	                   :partial => "spree/admin/hooks/user_form_retailers",
	                   :disabled => false)
