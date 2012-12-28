Deface::Override.new(:virtual_path => "spree/layouts/admin/_login_nav",
                    :name => "replace_admin_store_link",
                    :sequence => 1, 
                    :replace => "code[erb-loud]:contains('products_path')",
                    :text => "<%= link_to t(:store), spree.root_path %>",
                    :disabled => false)
