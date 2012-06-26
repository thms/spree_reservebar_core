Deface::Override.new(:virtual_path => "spree/products/index",
	                   :name => "store_products_search",
	                   :insert_top => "[data-hook='homepage_products']",
	                   :text => "<% if @no_products_found %><h6 class='search-results-title'><%= t(:no_products_found) %></h6><% end %>",
	                   :disabled => false)
