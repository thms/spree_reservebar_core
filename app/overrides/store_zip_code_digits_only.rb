Deface::Override.new(:virtual_path => "spree/checkout/_address",
	                   :name => "store_zip_code_digits_only",
	                   :insert_before => ".form-buttons",
	                   :partial => "spree/checkout/zip_code_digits_only",
	                   :sequence => 200, 
	                   :disabled => false)
