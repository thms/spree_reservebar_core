Deface::Override.new(:virtual_path => "spree/admin/users/_form",
	                   :name => "admin_user_form_roles",
	                   :replace => "code[erb-loud]:contains('check_box_tag')",
	                   :partial => "spree/admin/hooks/user_form_roles",
	                   :disabled => false)
