Deface::Override.new(:virtual_path => "spree/admin/shipments/index",
                     :name => "admin_shipment_tracking_link",
                     :replace => "code[erb-loud]:contains('shipment.tracking')",
                     :partial => "spree/admin/shared/tracking_link",
                     :disabled => false)
