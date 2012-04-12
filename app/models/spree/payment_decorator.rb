Spree::Payment.class_eval do
  
  def payment_method
    gateway = Spree::PaymentMethod.find(self.payment_method_id)
    if self.order && self.order.retailer
      gateway.set_provider(self.order.retailer.gateway_login, self.order.retailer.gateway_password)
    end
    gateway
  end
end