Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "retailers_admin_tabs",
                     :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                     :text => "<%= tab(:retailers, :url => spree.admin_retailers_path) %>",
                     :disabled => false)
