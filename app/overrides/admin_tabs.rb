# Limit admin tabs to orders and overview when the user is a retailer
Deface::Override.new(:virtual_path => "spree/layouts/admin",
                    :name => "replace_admin_tabs_for_retailer",
                    :sequence => 1, # apply before all others
                    :replace => "[data-hook='admin_tabs']",
                    :partial => "spree/admin/shared/admin_tabs",
                    :disabled => false)
