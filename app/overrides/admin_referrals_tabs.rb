Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "referrals_admin_tabs",
                     :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                     :text => "<%= tab(:referrals, :url => spree.admin_referrals_path) %>",
                     :disabled => false)
