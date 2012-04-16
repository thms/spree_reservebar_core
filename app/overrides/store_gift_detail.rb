Deface::Override.new(:virtual_path => "spree/checkout/edit",
	                   :name => "gift_form",
	                   :insert_after => "code[erb-loud]:contains('checkout_form_')",
	                   :partial => "spree/checkout/gift",
	                   :disabled => false)


Deface::Override.new(:virtual_path => "spree/orders/show",
	                   :name => "store_gift_detail",
	                   :insert_after => "code[erb-loud]:contains('shared/order_details')",
	                   :partial => "spree/hooks/gift_detail",
	                   :disabled => false)

