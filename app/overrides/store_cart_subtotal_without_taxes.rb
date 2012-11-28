Deface::Override.new(:virtual_path => "spree/orders/edit",
                     :name => "cart_subtotal_without_taxes",
                     :replace_contents => "#subtotal",
                     :partial => "spree/orders/subtotal_without_taxes",
                     :disabled => false)