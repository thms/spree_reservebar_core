Deface::Override.new(:virtual_path => "spree/products/show",
                     :name => "product_add_campaign_chunk",
                     :insert_before => "#product-description",
                     :partial => "spree/shared/campaign_chunk",
                     :disabled => false)
