# add unread class name to orders list
Deface::Override.new(:virtual_path => "spree/admin/orders/index",
                     :name => "add_unread_class_to_orders_list",
                     :set_attributes => "[data-hook='admin_orders_index_rows']",
                     :attributes => {:class => "<% if order.unread && order.retailer_id == session[:current_retailer_id] %>unread<% end %>"})
