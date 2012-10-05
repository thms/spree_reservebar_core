Deface::Override.new(:virtual_path => "spree/products/show",
                     :name => "product_add_legal_terms",
                     :insert_after => "[data-hook='cart_form']",
                     :partial => "spree/products/legal_terms",
                     :disabled => false)
