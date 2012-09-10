require 'spree/reservebar_core/retailer_selector'
require 'exceptions'

Spree::CheckoutController.class_eval do
  before_filter :set_gift_params, :only => :update
  
  # if we don't have a retailer that can ship alcohol to the state, we need to send a warning flag and thorug th usr back to the address state
  rescue_from Exceptions::NoRetailerShipsToStateError, :with => :rescue_from_no_retailer_ships_to_state_error

  # if the retailer selector did not find a retailer that can ship the whole order
  rescue_from Exceptions::NoRetailerCanShipFullOrderError, :with => :rescue_from_no_retailer_can_ship_full_order_error

  # if the user has not accetped the legal drinking age flag, we bail
  rescue_from Exceptions::NotLegalDrinkingAgeError, :with => :rescue_from_not_legal_drinking_age_error

  # Before we proceed to the delivery step we need to make a selection for the retailer based on the 
  # Shipping address selected earlier and the order contents
  # The retailer selector will return false if we cannot ship to the state.
  # Need to handle that some way or other.
  def before_delivery

    retailer = Spree::ReservebarCore::RetailerSelector.select(current_order)
    
    # And save the association between order and retailer
    if retailer.id != current_order.retailer_id
      current_order.retailer = retailer
      # Somehow this got lost along the way, force it here, where the retailer (and therefore the tax rate) is known
      # If the retailer is changed, we need to recreate the tax charge
      current_order.create_tax_charge!
    end
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
  
  
	protected
  
  def set_gift_params
    return unless params[:order] && params[:state] == "address"
		
    if params[:order][:is_gift].to_i == 0
      params[:order].delete(:gift_attributes)
    end
  end
  
  # called if user attempts to place order in state where we don't ship alcohol to
  def rescue_from_no_retailer_ships_to_state_error
    flash[:error] = "Thank you for attempting to make a purchase with ReserveBar. We appreciate your business; unfortunately we cannot accept your order. The reason for this is ReserveBar cannot currently deliver to your intended state due to that state's regulations.  Please sign up for an <%= link_to 'email notification', '/account' %> for when states are added to our offering, and you will receive a discount coupon for future purchase.<br />In the meantime, if you have other gifting needs for delivery in other states, we invite you to continue shopping. Delivery information is provided on every product detail page (just under the &lquot;Add to Cart&rquot; button). You can also review our delivery map at <%= link_to 'www.reservebar.com/delivery', '/delivery' %>. We apologize for the inconvenience and thank you again for gifting with ReserveBar."
    redirect_to cart_path
  end
  
  # Retailer selector did not find a retailer that can ship the entire order, but there are retailers shipping somethign to the state
  # Need to run search to see if there is a posible order split and what messaging to display
  def rescue_from_no_retailer_can_ship_full_order_error
    flash[:error] = "Catch all for all other scenarios - we are not able to ship all items to you..."
    redirect_to cart_path
  end
  
  # called if user attempts to place order without accepting the legal drinking age
  def rescue_from_not_legal_drinking_age_error
    flash[:error] = "You need to be of legal drinking age."
    render :edit
  end
  
  
end
