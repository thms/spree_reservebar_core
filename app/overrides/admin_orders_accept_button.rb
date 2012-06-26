Deface::Override.new(:virtual_path => "spree/admin/orders/show",
                     :name => "admin_orders_accept_button",
                     :insert_top => "[data-hook='admin_order_show_buttons']",
                     :partial => "/spree/admin/orders/accept_button",
                     :disabled => false)
