Spree::OrdersController.class_eval do
  require 'exceptions'

  before_filter :check_bottle_number_limit, :only => [:populate, :update]
  
  rescue_from Exceptions::BottleLimitPerOrderExceededError, :with => :bottle_limit_exceeded
  
  # Add customization to line item after the other stuff 
  after_filter :handle_customization, :only => [:populate, :update]
  
  protected
  
  # We'll need to add customization data to the SKU's either when it was submitted in the form or when the SKU requires it but it has not been 
  # submitted. The latter happens when SKUis added to the cart from a taxon page, where the form data is not available.
  def handle_customization
    @order = current_order(false)
    # Process if we got customization data from the product or cart page
    if params[:customization]
      # Find line item that can be customized, and set its preferred_customization_data
      begin
        line_item = @order.line_items.joins(:variant).where(:spree_variants => {:sku => 'JWBCEB'}).first
        line_item.preferred_customization = params[:customization].to_json 
      rescue Exception => e
        # Don't do anything for now
        Rails.logger.warn "Failed updating line item with customization data. Order #{@order.number}"
      end
    else # Check if a customizable SKU has been added without the customizatiob data in the form
      # Find line item that can be customized, and set its preferred_customization_data
      begin
        line_item = @order.line_items.joins(:variant).where(:spree_variants => {:sku => 'JWBCEB'}).first
        line_item.preferred_customization = {'type' => 'jwb_engraving', 'data' => {'line1' => '', 'line2' => '', 'line3' => ''}}
      rescue Exception => e
        # Don't do anything for now
        Rails.logger.warn "Failed updating line item with customization data. Order #{@order.number}"
      end        
    end
  end
  

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
    if params[:order] && params[:order][:line_items_attributes]
  	  params[:order][:line_items_attributes].each do |index, attributes|
  		  bottles_total += attributes['quantity'].to_i
  	  end 
	  end
	  if (@order.number_of_bottles + bottles_to_add > 12) || (bottles_total > 12)
      raise Exceptions::BottleLimitPerOrderExceededError
    end
  end

end

