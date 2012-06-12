require 'spree/reservebar_core/retailer_selector'
require 'exceptions'

Spree::CheckoutController.class_eval do
  before_filter :set_gift_params, :only => :update
  
  # if we don't have a retailer in the state, we need to send a warning flag and thorug th usr back to the address state
  rescue_from Exceptions::NoRetailerInStateError, :with => :rescue_from_no_retailer_in_state_error


  # if the user has not accetped the legal drinking age flag, we bail
  rescue_from Exceptions::NotLegalDrinkingAgeError, :with => :rescue_from_not_legal_drinking_age_error

  # Before we proceed to the delivery step we need to make a selection for the retailer based on the 
  # Shipping address selected earlier and the order contents
  # The retailer selector will return false if we cannot ship to the state.
  # Need to handle that some way or other.
  def before_delivery
    retailer = Spree::ReservebarCore::RetailerSelector.select(current_order)
    unless retailer
      raise Exceptions::NoRetailerInStateError
      Rails.logger.warn "No retailer in state found retailer"
    end
    Rails.logger.warn "Selected retailer #{retailer.id}"
    # And save the association between order and retailer
    current_order.retailer = retailer
  end


  def before_payment
    current_order.payments.destroy_all if request.put?
  end
  
  def before_address
    @order.bill_address ||= Spree::Address.default
    @order.ship_address ||= Spree::Address.default
    @order.gift.destroy if request.put? && @order.gift
    @order.gift_id = nil if request.put?
  end
  
  # try here
#  def after_payment
#    @order.validate_legal_drinking_age?
#  end
  
	protected
  
  def set_gift_params
    return unless params[:order] && params[:state] == "address"
		
    if params[:order][:is_gift].to_i == 0
      params[:order].delete(:gift_attributes)
    end
  end
  
  # called if user attempts to place order in state where we don;t have a retailer
  def rescue_from_no_retailer_in_state_error
    flash[:error] = "We are sorry, but we cannot ship to #{@order.ship_address.state.name} at this time. Please change your shipping address."
    redirect_to cart_path
  end
  
  # called if user attempts to place order without accepting the legal drinking age
  def rescue_from_not_legal_drinking_age_error
    flash[:error] = "You need to be of legal drinking age."
    render :edit
  end
  
  
end
