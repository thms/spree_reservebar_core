Spree::OrderMailer.class_eval do
  def gift_notify_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('order_mailer.gift_notify_email.subject')} ##{order.number}"
    mail(:to => order.gift.email,
         :subject => subject)
  end
end
