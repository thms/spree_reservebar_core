# Insert on cart page
Deface::Override.new(:virtual_path => "spree/orders/edit",
	                   :name => "brighttag_cart",
	                   :insert_before => "h1",
	                   :partial => "spree/brighttag_tags/cart",
	                   :disabled => false)

# Insert on order summary page 
Deface::Override.new(:virtual_path => "spree/orders/show",
	                   :name => "brighttag_order_summary",
	                   :insert_before => "#order",
	                   :partial => "spree/brighttag_tags/orders_show",
	                   :disabled => false)
	                   
# Insert on taxon page - taxon dependency is handled in the partial
Deface::Override.new(:virtual_path => "spree/taxons/show",
	                   :name => "brighttag_taxon_show",
	                   :insert_before => ".taxon-title",
	                   :partial => "spree/brighttag_tags/taxon_show",
	                   :disabled => false)


# Insert on product page
Deface::Override.new(:virtual_path => "spree/products/show",
	                   :name => "brighttag_product_show",
	                   :insert_before => ".product-title",
	                   :partial => "spree/brighttag_tags/product_show",
	                   :disabled => false)


