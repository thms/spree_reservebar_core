Deface::Override.new(:virtual_path => "spree/admin/overview/index",
	                   :name => "admin_retailer_select",
	                   :insert_after => "h1",
	                   :partial => "spree/admin/hooks/retailer_select",
	                   :disabled => false)
	                   
Deface::Override.new(:virtual_path => "spree/admin/orders/index",
	                   :name => "admin_retailer_select",
	                   :insert_after => "h1",
	                   :partial => "spree/admin/hooks/retailer_select",
	                   :disabled => false)
                   	
