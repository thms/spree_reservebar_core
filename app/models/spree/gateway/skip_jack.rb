class Spree::Gateway::SkipJack < Spree::Gateway
	preference :login, :string
	preference :password, :string

  def provider_class
    ActiveMerchant::Billing::SkipJackGateway
  end

  def options
    # add :test key in the options hash, as that is what the ActiveMerchant::Billing::SkipJackGateway expects
    if self.prefers? :test_mode
      self.class.default_preferences[:test] = true
    else
      self.class.default_preferences.delete(:test)
    end

    super
  end
  
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
    @provider ||= provider_class.new(gateway_options)
  end
  
end
