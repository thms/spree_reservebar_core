Spree::Gateway::Bogus.class_eval do

  # Normally the gateway reads the preferences from the preference database
  # We want to force the gateway to use the login and password from the retailer associated with the payment
  # See CreditCard class decorator for changes
  # after gateway = payment.payment_method call gateway.set_provider(payment.order.retailer.gateway_login, payment.order.retailer.gateway_password)
  def set_provider(login, password)
    gateway_options = options
    @provider ||= provider_class.new(gateway_options)
  end
end
