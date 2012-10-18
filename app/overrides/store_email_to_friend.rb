Deface::Override.new(:virtual_path => "spree/email_sender/send_mail",
                     :name => "product_email_sender_sanitize_title",
                     :replace => "code[erb-loud]:contains('tell_about')",
                     :text => "<%= sanitize(t('email_to_friend.tell_about', :product => @object.name), :tags => %w(sup)) %>",
                     :disabled => false)
                     
Deface::Override.new(:virtual_path => "spree/email_sender/send_mail",
                     :name => "product_email_sender_remove_captcha",
                     :replace => "code[erb-loud]:contains('recaptcha_tags')",
                     :text => "",
                     :disabled => false)
