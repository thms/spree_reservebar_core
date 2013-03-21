Deface::Override.new(:virtual_path => "spree/admin/shared/_product_tabs",
                     :name => "add_product_retailer_routes_tab",
                     :insert_bottom => "[data-hook='admin_product_tabs']",
                     :partial => "spree/admin/products/retailer_routes_tab",
                     :disabled => false)