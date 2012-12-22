Deface::Override.new(:virtual_path => "spree/shared/_order_details",
	                   :name => "order_details_adjustments_sales_tax_last",
	                   :replace => "[data-hook='order_details_adjustments']",
	                   :partial => "spree/orders/details_adjustments",
	                   :disabled => false)