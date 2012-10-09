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
  
  
  # Send out delivery notifications to giftor and copy mangement bar
  def after_deliver
    # Send email to giftor, if this order was a gift
    Spree::OrderMailer.giftor_delivered_email(self.order).deliver() if self.order.is_gift?
  end
     
  
end