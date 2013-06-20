Spree::Gateway::AuthorizeNetCim.class_eval do

  # Normally the gateway reads the preferences from the preference database
  # We want to force the gateway to use the login and password from the retailer associated with the payment
  # See CreditCard class decorator for changes
  # after gateway = payment.payment_method call gateway.set_provider(payment.order.retailer.gateway_login, payment.order.retailer.gateway_password)
  def set_provider(login, password)
    gateway_options = options
    gateway_options.delete :login if gateway_options.has_key?(:login)
    gateway_options.delete :password if gateway_options.has_key?(:password)
    gateway_options[:login] = login
    gateway_options[:password] = password
    ActiveMerchant::Billing::Base.gateway_mode = gateway_options[:server].to_sym
    @provider ||= ActiveMerchant::Billing::AuthorizeNetCimGateway.new(gateway_options)
  end
  
  # Here we need to override cim_gateway as well, since the implementation is different from AuthorizeNet class
  def cim_gateway
    @provider
  end
end
