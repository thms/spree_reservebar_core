Spree::Admin::OrdersController.class_eval do

	before_filter :load_retailer
	after_filter :sync_unread, :only => [:show, :summary]
	
#	skip_before_filter :authorize_admin, :only => :gift_message
  
	# Allow export of orders via CSV
  respond_to :csv, :only => :export
  
  def show
    respond_with(@order) do |format|
      if current_user.has_role?("admin")
        format.html {render}
      else
        format.html {render :action => :summary}
      end
    end
  end
  
  
	def index
	  params[:search] ||= {}
	  params[:search][:completed_at_is_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
	  @show_only_completed = params[:search][:completed_at_is_not_null].present?
	  params[:search][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'

	  @search = Spree::Order.metasearch(params[:search])

	  if !params[:search][:created_at_greater_than].blank?
	    params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
	  end

	  if !params[:search][:created_at_less_than].blank?
	    params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
	  end

	  if @show_only_completed
	    params[:search][:completed_at_greater_than] = params[:search].delete(:created_at_greater_than)
	    params[:search][:completed_at_less_than] = params[:search].delete(:created_at_less_than)
	  end
		
		if @current_retailer
			@orders = @current_retailer.orders.metasearch(params[:search]).includes([:user, :shipments, :payments]).page(params[:page]).per(Spree::Config[:orders_per_page])
		else
		  @orders = Spree::Order.metasearch(params[:search]).includes([:user, :shipments, :payments]).page(params[:page]).per(Spree::Config[:orders_per_page])
		end
		respond_with(@orders)
	end

	def export
	  params[:search] ||= {}
	  params[:search][:completed_at_is_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
	  @show_only_completed = params[:search][:completed_at_is_not_null].present?
	  params[:search][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'
    params[:search][:state_does_not_equal] = 'canceled'
    
	  @search = Spree::Order.metasearch(params[:search])

	  if !params[:search][:created_at_greater_than].blank?
	    params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
	  end

	  if !params[:search][:created_at_less_than].blank?
	    params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
	  end

	  if @show_only_completed
	    params[:search][:completed_at_greater_than] = params[:search].delete(:created_at_greater_than)
	    params[:search][:completed_at_less_than] = params[:search].delete(:created_at_less_than)
	  end

		@includes = [:user, :shipments, :payments, :line_items]
		if @current_retailer
			@orders = @current_retailer.orders.metasearch(params[:search]).includes(@includes)
		else
		  @orders = Spree::Order.metasearch(params[:search]).includes(@includes)
		end
		respond_with(@orders)
	end


  # Change the currently selected retailer, only avaialble to an admin user.
  def get_retailer_data
  	if params[:retailer_id] && !params[:retailer_id].empty?
  		session[:current_retailer_id] = params[:retailer_id]
  	else
  		session[:current_retailer_id] = nil
  	end

    redirect_to "/admin/orders"
  end
  
    
  # Purpose: retailer accepts the order
  def accept
    load_order
    if @order.accepted_at.blank? && (@current_retailer && @current_retailer.id == @order.retailer_id)
    	@order.update_attribute(:accepted_at, Time.now)
    	
    	# If the order only has one payment on it (all order here should have only a single payment)
    	# and the total order amount is lower than the payment amount, due to adjustments made after the order was submitted
    	# reduce the amount in the payment to the order total
    	if @order.payments.count == 1 && @order.payment.pending? && @order.total < @order.payment.amount
    	  @order.payment.update_attribute(:amount, @order.total)
    	  @order.payments.reload
  	  end
  	  
    	begin
    	  @order.payments.each do |payment|
    	    payment.payment_source.send("capture", payment)
  	    end
  	    # We disable this notification for now, until there is a better scheme of notifications decided
      	## Spree::OrderMailer.accepted_notification(@order).deliver
  	  rescue Spree::Core::GatewayError => error
  	    # Handle messaging to retailer - error flash that something
  	    flash[:error] = "Something went wrong with the payment on this order. Please hold off on shipping and contact ReserveBar."
  	    # Dump error to separate log
  	    log_payment_error(error)
  	    # Send email to reservbar that something went wrong
  	    Spree::OrderMailer.capture_payment_error_notification(@order, error).deliver
  	    @order.update_attribute(:accepted_at, nil)
	    end
    end
    redirect_to admin_order_url(@order)
  end
  
  # Purpose: retailer has packed the order and it is ready for pick up by Fedex / Courier
  def order_complete
    load_order
    if @order.packed_at.blank? && (@current_retailer && @current_retailer.id == @order.retailer_id)
    	@order.update_attribute(:packed_at, Time.now)
    end
    redirect_to admin_order_url(@order)
  end

  # used for testing only to preview the email
  def giftor_shipped_email
    load_order
    respond_with(@order) do |format|
      format.html { render :template => "spree/order_mailer/giftor_shipped_email.html.erb", :layout => false }
    end
  end

  # used for testing only to preview the email
  def retailer_submitted_email
    load_order
    respond_with(@order) do |format|
      format.html { render :template => "spree/order_mailer/retailer_submitted_email.html.erb", :layout => false }
    end
  end

  # used for testing only to preview the email

  def regular_reminder_email
    @retailers = Spree::Retailer.active
    
    respond_to do |format|
      format.html { render :template => "spree/order_mailer/regular_reminder_email.html.erb", :layout => false }
    end
  end
  
  # Retailer view of order, build up separately here and potentially fold into the show with a different render statement
  def summary
    
  end


	private

	def load_retailer
    if current_user.has_role?("admin")
    	if session[:current_retailer_id]
    		@current_retailer = Spree::Retailer.find(session[:current_retailer_id])
    	end
    elsif current_user.has_role?("retailer")
		  @current_retailer = current_user.retailer
    end
  end

  def sync_unread
  	@order.update_attributes(:unread => false, :viewed_at => Time.now) if @order.unread && (@order.retailer && @order.retailer == @current_retailer)
  end
  
  def log_payment_error(exception)
    new_logger = Logger.new('log/payment_errors.log')
    new_logger.info("\n\n===== Exception Caught at #{Time.now} for Order Number #{order.number} =====")
    new_logger.info(exception.message)
    new_logger.info("\n\n===== End Exception  =====\n\n")
  end

  

end
