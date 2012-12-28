Deface::Override.new(:virtual_path => 'spree/admin/shipments/_form',
                      :name => 'add_ship_events_to_shipment_form',
                      :insert_before => "[data-hook='admin_shipment_form_address']",
                      :partial => 'spree/admin/shipments/ship_events',
                      :diabled => false)
                      
                      
