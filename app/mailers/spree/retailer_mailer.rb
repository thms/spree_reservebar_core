module Spree
  class RetailerMailer < ActionMailer::Base
    helper 'spree/base'
    default :from => "ReserveBar Orders <no-reply@reservebar.com>"

    def regular_reminder_email(retailer, resend=false)
      @retailer = retailer
      subject = "#{Spree::Config[:site_name]} #{t('retailer_mailer.regular_reminder_email.subject')}"
      mail(:to => retailer.email, :reply_to => "orders@reservebar.com", :subject => subject)
    end
  end
end
