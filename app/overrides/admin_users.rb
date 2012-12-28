Deface::Override.new(:virtual_path => "spree/admin/users/index",
                     :name => "admin_users_export_csv",
                     :insert_after => "#listing_users",
                     :partial => "/spree/admin/users/export_csv",
                     :disabled => false)
