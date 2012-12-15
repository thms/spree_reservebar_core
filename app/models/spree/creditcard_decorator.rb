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

    record_log payment, response

    if response.success?
      Payment.create(:order => payment.order,
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
  
  
end
