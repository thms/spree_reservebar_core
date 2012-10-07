Spree::OrdersController.class_eval do
  require 'exceptions'

  before_filter :check_bottle_number_limit, :only => [:populate, :update]
  
  rescue_from Exceptions::BottleLimitPerOrderExceededError, :with => :bottle_limit_exceeded
  
  
  protected
  

  def bottle_limit_exceeded
    respond_to do |format|
      format.html {
        flash[:notice] = "<p>Thank you for trying to add products to your shopping cart. We appreciate your business; however,  we currently cannot accept an order that contains more than 12 bottles. </p>
    		<p>If you wish to purchase more than 12 bottles (e.g., more than one case of wine), please create separate orders, each of which must contain 12 or fewer bottles. We apologize for the inconvenience.</p>".html_safe
        redirect_to cart_path
      }
      format.js {
        render :populate_bottle_limit_exceeded
      }
    end
  end
  
  # Do not allow the user to add more than 12 bottles to the order.
  # If he tries, show him a message instead of allowing it
  def check_bottle_number_limit
    @order = current_order(true)
    
    # calculate number of bottles user is trying to add:
    bottles_to_add = 0
	  # populate method has either products or variants:
    params[:products].each do |product_id,variant_id|
      bottles_to_add += params[:quantity].to_i if !params[:quantity].is_a?(Hash)
      bottles_to_add += params[:quantity][variant_id.to_i].to_i if params[:quantity].is_a?(Hash)
     end if params[:products]

    params[:variants].each do |variant_id, quantity|
      bottles_to_add += quantity.to_i
    end if params[:variants]

	  # update method has "order"=>{"line_items_attributes"=>{"0"=>{"quantity"=>"1", "id"=>"111"}, "1"=>{"quantity"=>"10", "id"=>"113"}}}
    bottles_total = 0
	  params[:order][:line_items_attributes].each do |index, attributes|
		  bottles_total += attributes['quantity'].to_i
	  end if params[:order][:line_items_attributes]
	
	  if (@order.number_of_bottles + bottles_to_add > 12) || (bottles_total > 12)
      raise Exceptions::BottleLimitPerOrderExceededError
    end
  end

end

