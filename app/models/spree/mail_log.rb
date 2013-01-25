# Purpose: Keep track of which email has already been sent for an order so that we do not send the same email more than once
module Spree
  class MailLog < ActiveRecord::Base
    
    set_table_name 'spree_mail_log'
    
    belongs_to :order
    validates_uniqueness_of :mail_class, :scope => :order_id
    
    # Sanity check whether the email has already been sent at an eallier time, if so do not send again
    def self.has_email_been_sent_already?(order, mail_class)
      mail_log = Spree::MailLog.new(:order_id => order.id, :mail_class => mail_class)
      if mail_log.valid?
        mail_log.save
        return false
      else
        return true
      end
    end
    
    
  end
end