Deface::Override.new(:virtual_path => "spree/admin/orders/show",
                     :name => "admin_orders_address_is_business",
                     :insert_after => "code[erb-loud]:contains('@order.ship_address')",
                     :text => "<%= @order.ship_address.is_business ? 'This is a business address.' : 'This is a residential address.' %>",
                     :disabled => false)
                     
Deface::Override.new(:virtual_path => "spree/admin/shared/_address_form",
  :name => "admin_orders_address_type",
  :insert_after => "code[erb-loud]:contains('f.text_field :phone')",
  :text => " <%= f.check_box :is_business %> This is a business address.",
  :disabled => false)
