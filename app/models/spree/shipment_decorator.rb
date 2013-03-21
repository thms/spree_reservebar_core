Spree::Shipment.class_eval do
  
  # Shipment detail stores the ship response from Fedex, including the label, price, etc.
  has_one :shipment_detail
  
  # indicates that a shipment has a tracking number and is trackable
  scope :trackable, where("tracking is not null")
  
  # indicates that a shipment has been delivered
  scope :delivered, where(:state => 'delivered')
  
  # add the delivered state to the shipment
  state_machine  :use_transactions => false do 
    
    event :deliver do
      transition :from => 'shipped', :to => 'delivered'
    end
    

    after_transition :to => 'delivered', :do => :after_deliver
  end
  
  # OVerride here to add the delivered state to the system
  # Determines the appropriate +state+ according to the following logic:
  #
  # pending    unless +order.payment_state+ is +paid+
  # shipped    if already shipped (ie. does not change the state)
  # ready      all other cases
  # TODO: Issue with order state going back to balance due when changes are made to the order in admin. 
  #       In that case, the shipment goes again through the pending, - shipped - delivered cycle and the more they muck with 
  #       orders, the more that happens. Then at every state transition, there the order emails are sent again.
  #       So, once a shipment is shipped or delivered, it does not change back to pending or ready
  def determine_state(order)
    return 'pending' if self.inventory_units.any? { |unit| unit.backordered? }
    return 'shipped' if state == 'shipped'
    return 'delivered' if state == 'delivered'
    # Original, that resulted in emails being delivered several times:
    # order.payment_state == 'balance_due' ? 'pending' : 'ready'
    # Updated version that should prevent that from happening:
    order.payment_state == 'balance_due' ? 'pending' : 'ready'
    
  end
  
  
  # Override here to avoid sending the stock email and instead send the (wrongly placed) new emails
  def after_ship
    inventory_units.each &:ship!
    Spree::OrderMailer.giftor_shipped_email(self.order).deliver() unless Spree::MailLog.has_email_been_sent_already?(self.order, 'Order::giftor_shipped_email')
    Spree::OrderMailer.giftee_shipped_email(self.order).deliver() if (self.order.is_gift? && !self.order.gift.email.blank? && !Spree::MailLog.has_email_been_sent_already?(order, 'Order::giftee_shipped_email'))
  end
  
  
  
  # Send out delivery notifications to giftor and copy mangement bar
  def after_deliver
    # Send email to giftor, if this order was a gift, so that he knows it has been delivered to the giftee
    Spree::OrderMailer.giftor_delivered_email(self.order).deliver() if (self.order.is_gift? && !Spree::MailLog.has_email_been_sent_already?(self.order, 'Order::giftor_delivered_email'))
  end
  
  def deliver!
    self.update_attribute_without_callbacks(:state, 'delivered')
    self.order.send(:update_shipment_state)
    self.order.update_attributes_without_callbacks({:shipment_state => self.order.shipment_state})
    Spree::OrderMailer.giftor_delivered_email(self.order).deliver() if (self.order.is_gift? && !Spree::MailLog.has_email_been_sent_already?(self.order, 'Order::giftor_delivered_email'))
  end
  
  # Overrride original to account for deliverd state
  def editable_by?(user)
    !shipped? && !delivered?
  end
  
  # Returns the number of bottles in the shipment
  # Cache counts?
  def number_of_bottles
    bottles = self.line_items.inject(0) {|bottles, line_item| bottles + line_item.quantity}
  end
  
     
  
end