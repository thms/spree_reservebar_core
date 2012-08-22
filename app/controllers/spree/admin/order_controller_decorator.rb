Spree::Admin::OrdersController.class_eval do

	before_filter :load_retailer
	after_filter :sync_unread, :only => [:show]
	
#	skip_before_filter :authorize_admin, :only => :gift_message
  
	# Allow export of orders via CSV
  respond_to :csv, :only => :index
  
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


  def get_retailer_data
  	if params[:retailer_id] && !params[:retailer_id].empty?
  		session[:current_retailer_id] = params[:retailer_id]
  	else
  		session[:current_retailer_id] = nil
  	end

    redirect_to "/admin/orders"
  end
  
  def accept
    load_order
    if @order.accepted_at.blank? && (@current_retailer && @current_retailer.id == @order.retailer_id)
    	@order.update_attribute(:accepted_at, Time.now)
    	Spree::OrderMailer.accept_notify_email(@order).deliver
    end
    redirect_to admin_order_url(@order)
  end

	def confirm_email
		load_order
		
		respond_with(@order) do |format|
			format.html { render :template => "spree/order_mailer/confirm_email.html.erb", :layout => false }
		end
	end

	def gift_notify_email
		load_order
		
		respond_with(@order) do |format|
			format.html { render :template => "spree/order_mailer/gift_notify_email.html.erb", :layout => false }
		end
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
  	@order.update_attribute(:unread, false) if @order.unread && (@order.retailer && @order.retailer == @current_retailer)
  end
  

  

end
