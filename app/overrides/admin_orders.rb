Deface::Override.new(:virtual_path => "spree/admin/shared/_order_tabs",
                     :name => "admin_orders_extended_state",
                     :replace => "code[erb-loud]:contains('order_state')",
                     :partial => "spree/admin/shared/order_extended_state",
                     :disabled => false)
