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
  def determine_state(order)
    return 'pending' if self.inventory_units.any? { |unit| unit.backordered? }
    return 'shipped' if state == 'shipped'
    return 'delivered' if state == 'delivered'
    order.payment_state == 'balance_due' ? 'pending' : 'ready'
  end
  
  
  # Override here to avoid sending the stock email and instead send the (wrongly placed) new emails
  def after_ship
    inventory_units.each &:ship!
    Spree::OrderMailer.giftor_shipped_email(self.order).deliver()
    Spree::OrderMailer.giftee_shipped_email(self.order).deliver() if self.order.is_gift?
  end
  
  
  
  # Send out delivery notifications to giftor and copy mangement bar
  def after_deliver
    # Send email to giftor, if this order was a gift, so that he knows it has been delivered to the giftee
    Spree::OrderMailer.giftor_delivered_email(self.order).deliver() if self.order.is_gift?
  end
     
  
end