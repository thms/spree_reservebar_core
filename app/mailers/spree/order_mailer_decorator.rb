Spree::OrderMailer.class_eval do
  default :from => "ReserveBar Orders <no-reply@reservebar.com>"
  
  # sent to giftor
  def confirm_email(order, resend = false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : '')
    subject += "#{t('order_mailer.confirm_email.subject')}"
    mail(:to => order.email, :reply_to => "support@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end
  
  def cancel_email(order, resend = false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : '')
    subject += "#{t('order_mailer.cancel_email.subject')}"
    mail(:to => order.email, :reply_to => "order@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end
  
	def cancel_email(order, resend = false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : '')
    subject += "#{t('order_mailer.cancel_email.subject')}"
    mail(:to => order.email, :reply_to => "order@reservebar.com", :cc => "management@reservebar.com", :subject => subject)
  end

  def giftor_shipped_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.giftor_shipped_email.subject')}"
    mail(:to => order.email, :reply_to => "support@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end

  def giftor_delivered_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.giftor_delivered_email.subject')}"
    mail(:to => order.email, :reply_to => "support@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end

  # sent to giftee
  def giftee_notify_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.giftee_notify_email.subject')}"
    mail(:to => order.gift.email, :reply_to => "support@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end

  def giftee_shipped_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.giftee_shipped_email.subject')}"
    mail(:to => order.gift.email, :reply_to => "support@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end
  
  # sent to retailer
  def retailer_submitted_email(order, resend=false)
    @order = order
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.retailer_submitted_email.subject')}"
    mail(:to => order.retailer.email, :reply_to => "orders@reservebar.com", :bcc => "management@reservebar.com", :subject => subject)
  end
  
  # send email to reservebar.com that retailer has accepted an order
  def accepted_notification(order, resend = false)
    @order = order
    @retailer = @order.retailer
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.accepted_notification.subject')} ##{order.number}"
    mail(:to => "management@reservebar.com", :subject => subject)
  end
  
  # send email to reservebar.com with all orders that have not been accepted yet
  def not_accepted_notification(hours = 6, resend = false)
    @hours = hours
    @orders = Spree::Order.not_accepted_hours(hours).order("spree_orders.updated_at desc")
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "Orders that have not been accepted more than #{hours} hours"
    mail(:to => "management@reservebar.com", :subject => subject)
  end

  # Regular status email to management - indicates if any orders are not progressing as needed
  def regular_reminder_email(resend = false)
    @retailers = Spree::Retailer.active
    subject = (resend ? "[#{t(:resend).upcase}] " : "")
    subject += "#{t('order_mailer.regular_reminder_email.subject')}"
    mail(:to => "management@reservebar.com", :reply_to => "orders@reservebar.com", :subject => subject)
  end  
  
  # Send email to reservebar if a payment capture fails for some reason
  def capture_payment_error_notification(order, error)
    @order = order
    @error = error
    subject = "Payment Capture Failed - #{order.number}"
    mail(:to => "management@reservebar.com", :subject => subject)
  end
end
