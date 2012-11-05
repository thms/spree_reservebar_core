Deface::Override.new(:virtual_path => "spree/admin/shared/_order_tabs",
                     :name => "admin_orders_extended_state",
                     :insert_after => "#order_number",
                     :partial => "spree/admin/shared/order_extended_state",
                     :disabled => false)