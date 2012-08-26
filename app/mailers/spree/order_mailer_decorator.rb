Spree::OrderMailer.class_eval do
  def gift_notify_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('order_mailer.gift_notify_email.subject')} ##{order.number}"
    mail(:to => order.gift.email, :subject => subject)
  end
  
  # send email to reservebar.com that retailer has accepted an order
  def accepted_notification(order, resend = false)
    @order = order
    @retailer = @order.retailer
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "Reservebar - #{t('order_mailer.accepted_notification.subject')} ##{order.number}"
    mail(:to => "admin@reservebar.com", :subject => subject)
  end
  
  # send email to reservebar.com with all orders that have not been accepted yet
  def not_accepted_notification(hours = 6, resend = false)
    @hours = hours
    @orders = Spree::Order.not_accepted_hours(hours).order("spree_orders.updated_at desc")
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "Reservebar - Orders that have not been accepted more than #{hours} hours"
    mail(:to => "admin@reservebar.com", :subject => subject)
  end
  
end
