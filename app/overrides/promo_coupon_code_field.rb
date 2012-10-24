# Disable the coupon code field on the payments page as part of the form
# we'll move it up and outside of the form, so we can submit as Ajax request
Deface::Override.new(:virtual_path => "spree/checkout/_payment",
                     :name => "promo_coupon_code_field",
                     :replace => "[data-hook='coupon_code_field'], #coupon_code_field[data-hook]",
                     :partial => "spree/checkout/coupon_code_field",
                     :disabled => true)

# Insert Ajax form before payment form
Deface::Override.new(:virtual_path => "spree/checkout/edit",
                     :name => "promo_coupon_code_field_ajax",
                     :insert_top => "[data-hook='checkout_form_wrapper']",
                     :partial => "spree/checkout/coupon_code_field_ajax",
                     :disabled => false)
