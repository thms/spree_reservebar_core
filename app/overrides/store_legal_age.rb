Deface::Override.new(:virtual_path => "spree/checkout/_address",
#Deface::Override.new(:virtual_path => "spree/checkout/edit",
	                   :name => "is_legal_drinking_age",
	                   #:insert_after => "code[erb-loud]:contains('checkout_form_')",
	                   :insert_before => ".form-buttons",
	                   :partial => "spree/checkout/legal_age",
	                   :disabled => false)
