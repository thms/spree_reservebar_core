# Disabled this, since retailers are not supposed to see the link on the listing, only on the actual summary page
Deface::Override.new(:virtual_path => "spree/admin/orders/index",
                     :name => "admin_orders_accept_link",
                     :insert_top => "[data-hook='admin_orders_index_row_actions']",
                     :partial => "/spree/admin/orders/accept_link",
                     :disabled => true)

