Deface::Override.new(:virtual_path => "spree/admin/shared/_order_tabs",
                     :name => "admin_orders_extended_state",
                     :replace => "code[erb-loud]:contains('order_state')",
                     :partial => "spree/admin/shared/order_extended_state",
                     :disabled => false)
                     
Deface::Override.new(:virtual_path => "spree/admin/orders/show",
                     :name => "admin_orders_address_is_business",
                     :insert_after => "code[erb-loud]:contains('@order.ship_address')",
                     :text => "<%= @order.ship_address.is_business ? 'This is a business address.' : 'This is a residential address.' %>",
                     :disabled => false)
