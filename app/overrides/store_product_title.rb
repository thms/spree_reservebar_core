Deface::Override.new(:virtual_path => "spree/products/show",
                      :name => "product_sanitize_title",
                      :replace => "code[erb-loud]:contains('accurate_title')",
                      :text => "<%= sanitize @product.name, :tags => %w(sup) %>",
                      :disabled => false)
