require 'spree/reservebar_core/retailer_selector'
require 'spree/reservebar_core/order_splitter'
require 'exceptions'

Spree::CheckoutController.class_eval do
  
  # Ajax update for coupon codes
  respond_to :js, :only => [:apply_coupon]
  
  before_filter :set_gift_params, :only => :update
  
  # if we don't have a retailer that can ship alcohol to the state, we need to set a warning flag and throw the user back to the address state
  rescue_from Exceptions::NoRetailerShipsToStateError, :with => :rescue_from_no_retailer_ships_to_state_error

  # if the retailer selector did not find a retailer that can ship the whole order
  rescue_from Exceptions::NoRetailerCanShipFullOrderError, :with => :rescue_from_no_retailer_can_ship_full_order_error

  # if the user has not accetped the legal drinking age flag, we bail
  rescue_from Exceptions::NotLegalDrinkingAgeError, :with => :rescue_from_not_legal_drinking_age_error


  # Ajax call to apply coupon to order
  def apply_coupon
    if @order.update_attributes(object_params)

      fire_event('spree.checkout.update')

      if @order.coupon_code.present?

        if Spree::Promotion.exists?(:code => @order.coupon_code)
          fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
          # If it doesn't exist, raise an error!
          # Giving them another chance to enter a valid coupon code
          @message = "Coupon applied"
        else
          @message = t(:promotion_not_found)
        end
      end
      # Need to reload the order, otehrwise total is not updated
      @order.reload
      respond_with(@order, @message)
    end
  end


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
    flash[:notice] = "Thank you for attempting to make a purchase with ReserveBar. We appreciate your business; unfortunately we cannot accept your order. The reason for this is ReserveBar cannot currently deliver to your intended state due to that state's regulations.  
    Please sign up for an <a href='/account'>email notification</a> for when states are added to our offering, and you will receive a discount coupon for future purchase.<br />In the meantime, if you have other gifting needs for delivery in other states, we invite you to continue shopping. Delivery information is provided on every product detail page (just under the 'Add to Cart' button). You can also review our delivery map at <a href='/delivery'>www.reservebar.com/delivery</a>. We apologize for the inconvenience and thank you again for gifting with ReserveBar.".html_safe
    redirect_to cart_path
  end
  
  # Retailer selector did not find a retailer that can ship the entire order, but there are retailers shipping somethign to the state
  # Need to run search to see if there is a posible order split and what messaging to display
  def rescue_from_no_retailer_can_ship_full_order_error
    ##flash[:error] = "Catch all for all other scenarios - we are not able to ship all items to you..."
    # First check if we have items that we cannot ship at all to the state, but also have items that we can ship
    result = Spree::ReservebarCore::OrderSplitter.find_shippable_categories(current_order)
    if result[:unshippable].count > 0 && result[:shippable].count > 0
      shippable_names = Spree::ShippingCategory.find(result[:shippable]).map(&:name).join(', ')
      unshippable_names = Spree::ShippingCategory.find(result[:unshippable]).map(&:name).join(', ')
      flash[:notice] = "Thank you for attempting to purchase #{unshippable_names} and #{shippable_names} with ReserveBar. We appreciate your business; however, we currently cannot accept orders for delivery of #{unshippable_names} to your intended state due to that state's regulations. Fortunately, we are still able to accept the #{shippable_names} portion of your order for that state. Please remove #{unshippable_names} from your shopping cart and proceed through check out as normal.<br />   
      We realize this is not an ideal situation, but we trust our extensive selection of #{shippable_names} will provide your gift recipient an equally meaningful experience.  We apologize for the inconvenience and thank you again for gifting with ReserveBar.".html_safe
    elsif result[:unshippable].count > 0 && result[:shippable].count == 0
      # We can;t ship any of the items, tell the user what other items we can ship 
      shippable_names = Spree::ReservebarCore::RetailerSelector.find_shippable_category_names(current_order.ship_address.state)
      unshippable_names = Spree::ShippingCategory.find(result[:unshippable]).map(&:name).join(', ')
      flash[:notice] = "Thank you for attempting to purchase #{unshippable_names}, unfortunately, we currently cannot accept orders for delivery of #{unshippable_names} to your intended state due to that state's regulations.  However, we are able to accept orders for #{shippable_names} to be delivered to that state. Please remove #{unshippable_names} from your shopping cart and browse our extensive selection of #{shippable_names} for your gift purchase. <br />
      We realize this is not your first choice, but we trust our selection of #{shippable_names} will prove to be an attractive alternative.".html_safe
    else
      # we can ship all items to the state, but not by the same retailer, so find a shippable subset
      shipping_categories = current_order.shipping_categories
      result = Spree::ReservebarCore::OrderSplitter.full_search(shipping_categories, current_order.ship_address.state)
      if result 
        # We have a subset shippable by a single retailer
        shippable_names = Spree::ShippingCategory.find(result[:shippable]).map(&:name).join(', ')
        unshippable_names = Spree::ShippingCategory.find(result[:unshippable]).map(&:name).join(', ')
        flash[:notice] = "Thank you for attempting to purchase #{shippable_names} and #{unshippable_names} with ReserveBar. We appreciate your business; however, we currently cannot combine those alcohol categories into one order for your intended state due to that state's regulations. Please remove #{unshippable_names} items from your shopping cart and proceed through check out with #{shippable_names} only. 
        Then, we invite you to create a separate order with #{unshippable_names} items and proceed through check out with #{unshippable_names} only.".html_safe
      else
        # we do not have a subset shippable by a single retailer (should really never happen at this point, unless we need to recurse deeper)
        flash[:notice] = "Hmm, looks we cannot ship any of the items to your state."
      end
    end
    redirect_to cart_path
  end
  
  # called if user attempts to place order without accepting the legal drinking age
  def rescue_from_not_legal_drinking_age_error
    flash[:notice] = "You need to be of legal drinking age to place an order."
    render :edit
  end
    
  
end
