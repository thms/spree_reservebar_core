Spree::Shipment.class_eval do
  
  # Shipment detail stores the ship response from Fedex, including the label, price, etc.
  has_one :shipment_detail
  
  # indicates that a shipment has a tracking number and is trackable
  scope :trackable, where("tracking is not null")
  scope :delivered, where(:state => 'delivered')
  
  # add the delivered state to the shipment
  state_machine do 
    
    event :deliver do
      transition :from => 'shipped', :to => 'delivered'
    end
    
    after_transition :to => 'delivered', :do => :after_deliver
  end
  
  # Send out delivery notifications
  def after_deliver
  end
     
  
end