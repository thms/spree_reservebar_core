# Add UI to cart
Deface::Override.new(:virtual_path => "spree/products/_cart_form",
                     :name => "product_add_customization",
                     :insert_top => "[data-hook='inside_product_cart_form']",
                     :partial => "spree/products/customization",
                     :disabled => false)
                     
# Show on cart page with line item
Deface::Override.new(:virtual_path => "spree/orders/_line_item",
                     :name => "cart_add_customization",
                     :insert_bottom => "[data-hook='cart_item_description']",
                     :partial => "spree/orders/customization_cart",
                     :sequence => {:after => "cart_remove_item_description"},
                     :disabled => false)


# Show on order confirmation page with line item
Deface::Override.new(:virtual_path => "spree/shared/_order_details",
                     :name => "cart_add_customization",
                     :insert_bottom => "[data-hook='order_item_description']",
                     :partial => "spree/orders/customization_show",
                     #:sequence => {:after => "cart_remove_item_description"},
                     :disabled => false)

# Show on admin order show with line item
Deface::Override.new(:virtual_path => "spree/admin/orders/show",
                     :name => "admin_orders_add_custom_engraving_notice",
                     :insert_top => "[data-hook='admin_order_show_details']",
                     :partial => "/spree/admin/orders/customization",
                     :disabled => false)


