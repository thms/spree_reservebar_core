Spree::Creditcard.class_eval do
  
  # Override to make sure w get rid of spaces before trying to ge the type, fails otherwise
  # sets self.cc_type while we still have the card number
  def set_card_type
    self.cc_type ||= CardDetector.type?(self.number.to_s.gsub(/\s/,''))
  end
  
  
  # The implementation in this version of spree does not work, it is missing the credit card number / last four digits
  def credit(payment)
    payment_gateway = payment.payment_method
    check_environment(payment_gateway)

    amount = payment.credit_allowed >= payment.order.outstanding_balance.abs ? payment.order.outstanding_balance.abs : payment.credit_allowed.abs
    if payment_gateway.payment_profiles_supported?
      response = payment_gateway.credit((amount * 100).round, self, payment.response_code, minimal_gateway_options(payment, false))
    else
      options = {:card_number => payment.source.last_digits}.merge(minimal_gateway_options(payment, false))
      response = payment_gateway.credit((amount * 100).round, payment.response_code, options)
    end

    ## Thomas: add action here, until we update to a later version of active merchant
    response[:action] = "CREDIT" unless response[:action]
    record_log payment, response

    if response.success?
      Spree::Payment.create(:order => payment.order,
                            :source => payment,
                            :payment_method => payment.payment_method,
                            :amount => amount.abs * -1,
                            :response_code => response.authorization,
                            :state => 'completed')
    else
      gateway_error(response)
    end
  rescue ActiveMerchant::ConnectionError => e
    gateway_error e
  end
  
  
  ### THOMAS: The following three methods are duplicated here, so we can have the reponse set and logged, will become obsolete
  ## once we update to Active Merchant 1.28 or higher
  def authorize(amount, payment)
    # ActiveMerchant is configured to use cents so we need to multiply order total by 100
    payment_gateway = payment.payment_method
    check_environment(payment_gateway)

    response = payment_gateway.authorize((amount * 100).round, self, gateway_options(payment))
    ## Thomas: add action here, until we update to a later version of active merchant
    response[:action] = "AUTHORIZE" unless response[:action]
    record_log payment, response

    if response.success?
      payment.response_code = response.authorization
      payment.avs_response = response.avs_result['code']
      payment.pend
    else
      payment.failure
      gateway_error(response)
    end
  rescue ActiveMerchant::ConnectionError => e
    gateway_error e
  end

  def purchase(amount, payment)
    #combined Authorize and Capture that gets processed by the ActiveMerchant gateway as one single transaction.
    payment_gateway = payment.payment_method
    check_environment(payment_gateway)

    response = payment_gateway.purchase((amount * 100).round, self, gateway_options(payment))
    ## Thomas: add action here, until we update to a later version of active merchant
    response[:action] = "PURCHASE" unless response[:action]
    record_log payment, response

    if response.success?
      payment.response_code = response.authorization
      payment.avs_response = response.avs_result['code']
      payment.complete
    else
      payment.failure
      gateway_error(response) unless response.success?
    end
  rescue ActiveMerchant::ConnectionError => e
    gateway_error e
  end

  def capture(payment)
    return unless payment.pending?
    payment_gateway = payment.payment_method
    check_environment(payment_gateway)

    if payment_gateway.payment_profiles_supported?
      # Gateways supporting payment profiles will need access to creditcard object because this stores the payment profile information
      # so supply the authorization itself as well as the creditcard, rather than just the authorization code
      response = payment_gateway.capture(payment, self, minimal_gateway_options(payment, false))
    else
      # Standard ActiveMerchant capture usage
      response = payment_gateway.capture((payment.amount * 100).round, payment.response_code, minimal_gateway_options(payment, false))
    end

    ## Thomas: add action here, until we update to a later version of active merchant
    response[:action] = "CAPTURE" unless response[:action]
    record_log payment, response

    if response.success?
      payment.response_code = response.authorization
      payment.complete
    else
      payment.failure
      gateway_error(response)
    end
  rescue ActiveMerchant::ConnectionError => e
    gateway_error e
  end

  def void(payment)
    payment_gateway = payment.payment_method
    check_environment(payment_gateway)

    response = payment_gateway.void(payment.response_code, minimal_gateway_options(payment, false))
    ## Thomas: add action here, until we update to a later version of active merchant
    response[:action] = "VOID" unless response[:action]
    record_log payment, response

    if response.success?
      payment.response_code = response.authorization
      payment.void
    else
      gateway_error(response)
    end
  rescue ActiveMerchant::ConnectionError => e
    gateway_error e
  end
  
  #### END MONKEY PATCH
  
  
end
