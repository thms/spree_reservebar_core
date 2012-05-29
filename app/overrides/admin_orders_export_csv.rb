Deface::Override.new(:virtual_path => "spree/admin/orders/index",
                     :name => "admin_orders_export_csv",
                     :insert_after => "#listing_orders",
                     :partial => "/spree/admin/orders/export_csv",
                     :disabled => false)
