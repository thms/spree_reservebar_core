Deface::Override.new(:virtual_path => "spree/checkout/edit",
	                   :name => "is_legal_drinking_age",
	                   :insert_after => "code[erb-loud]:contains('checkout_form_')",
	                   :partial => "spree/checkout/legal_age",
	                   :disabled => false)
