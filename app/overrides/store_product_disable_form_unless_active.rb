Deface::Override.new(:virtual_path => "spree/products/show",
                     :name => "product_disable_form_unless_active",
                     :insert_after => "#cart-form",
                     :partial => "spree/products/not_active",
                     :disabled => false)
