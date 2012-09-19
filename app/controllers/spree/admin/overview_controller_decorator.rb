Spree::Admin::OverviewController.class_eval do
	before_filter :load_retailer, :only => [:index]
	
  def index
    @show_dashboard = show_dashboard
    return unless @show_dashboard

    p = {:from => (Time.new().to_date  - 1.week).to_s(:db), :value => "Count"}
    @orders_by_day = orders_by_day(p)
    @orders_line_total = orders_line_total(p)
    @orders_total = orders_total(p)
    @orders_adjustment_total = orders_adjustment_total(p)
    @orders_credit_total = orders_credit_total(p)

    @best_selling_variants = best_selling_variants
    @top_grossing_variants = top_grossing_variants
    @last_five_orders = last_five_orders
    @biggest_spenders = biggest_spenders
    @out_of_stock_products = out_of_stock_products
    @best_selling_taxons = best_selling_taxons

    @pie_colors = [ "#0093DA", "#FF3500", "#92DB00", "#1AB3FF", "#FFB800"]
    
    #@retailer = @current_retailer
  end
  
  def get_retailer_data
  	if params[:retailer_id] && !params[:retailer_id].empty?
  		session[:current_retailer_id] = params[:retailer_id]
  	else
  		session[:current_retailer_id] = nil
  	end

    redirect_to "/admin"
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
    
	  if @current_retailer
	  	@orders = @current_retailer.orders
	  end
  end
  
  def show_dashboard
    @current_retailer ? @current_retailer.orders.count >= 1 : Spree::Order.count >= 1
  end

  def orders_by_day(params)

    if params[:value] == "Count"
      if @current_retailer
      	orders = @orders.select(:created_at).where(conditions(params))
      else
      	orders = Spree::Order.select(:created_at).where(conditions(params))
      end
      orders = orders.group_by { |o| o.created_at.to_date }
      fill_empty_entries(orders, params)
      orders.keys.sort.map {|key| [key.strftime('%Y-%m-%d'), orders[key].size ]}
    else
      if @current_retailer
      	orders = @orders.select([:created_at, :total]).where(conditions(params))
      else
      	orders = Spree::Order.select([:created_at, :total]).where(conditions(params))
      end
      orders = orders.group_by { |o| o.created_at.to_date }
      fill_empty_entries(orders, params)
      orders.keys.sort.map {|key| [check_json_authenticitykey.strftime('%Y-%m-%d'), orders[key].inject(0){|s,o| s += o.total} ]}
    end
  end

  def orders_line_total(params)
    @current_retailer ? @orders.sum(:item_total, :conditions => conditions(params)) : Spree::Order.sum(:item_total, :conditions => conditions(params))
  end

  def orders_total(params)
    @current_retailer ? @orders.sum(:total, :conditions => conditions(params)) : Spree::Order.sum(:total, :conditions => conditions(params))
  end

  def orders_adjustment_total(params)
    @current_retailer ? @orders.sum(:adjustment_total, :conditions => conditions(params)) : Spree::Order.sum(:adjustment_total, :conditions => conditions(params))
  end

  def orders_credit_total(params)
    @current_retailer ? @orders.sum(:adjustment_total, :conditions => conditions(params)) : Spree::Order.sum(:credit_total, :conditions => conditions(params))
  end
  
  def best_selling_variants
    if @current_retailer
    	li = Spree::LineItem.includes(:order).where(["spree_orders.state = 'complete' and spree_orders.id in (?)", @current_retailer.order_ids]).sum(:quantity, :group => :variant_id, :limit => 5)
    else
    	li = Spree::LineItem.includes(:order).where("spree_orders.state = 'complete'").sum(:quantity, :group => :variant_id, :limit => 5)
    end
    variants = li.map do |v|
      variant = Spree::Variant.find(v[0])
      [variant.name, v[1] ]
    end
    variants.sort { |x,y| y[1] <=> x[1] }
  end

  def top_grossing_variants
    if @current_retailer
    	quantity = Spree::LineItem.includes(:order).where(["spree_orders.state = 'complete' and spree_orders.id in (?)", @current_retailer.order_ids]).sum(:quantity, :group => :variant_id, :limit => 5)
		  prices = Spree::LineItem.includes(:order).where(["spree_orders.state = 'complete' and spree_orders.id in (?)", @current_retailer.order_ids]).sum(:price, :group => :variant_id, :limit => 5)
    else
		  quantity = Spree::LineItem.includes(:order).where("spree_orders.state = 'complete'").sum(:quantity, :group => :variant_id, :limit => 5)
		  prices = Spree::LineItem.includes(:order).where("spree_orders.state = 'complete'").sum(:price, :group => :variant_id, :limit => 5)
    end
    variants = quantity.map do |v|
      variant = Spree::Variant.find(v[0])
      [variant.name, v[1] * prices[v[0]]]
    end

    variants.sort { |x,y| y[1] <=> x[1] }
  end

  #TODO: add @current_retailer conditions
  def best_selling_taxons
    taxonomy = Spree::Taxonomy.last
    taxons =  Spree::Taxon.connection.select_rows("select t.name, count(li.quantity) from spree_line_items li inner join spree_variants v on
           li.variant_id = v.id inner join spree_products p on v.product_id = p.id inner join spree_products_taxons pt on p.id = pt.product_id
           inner join spree_taxons t on pt.taxon_id = t.id where t.taxonomy_id = #{taxonomy.id} group by t.name order by count(li.quantity) desc limit 5;")
  end

  def last_five_orders
    if @current_retailer
    	orders = @orders.includes(:line_items).where("completed_at IS NOT NULL").order("completed_at DESC").limit(5)
    else
    	orders = Spree::Order.includes(:line_items).where("completed_at IS NOT NULL").order("completed_at DESC").limit(5)
    end
    orders.map do |o|
      qty = o.line_items.inject(0) {|sum,li| sum + li.quantity}
      name = @current_retailer ? o.bill_address.try(:full_name) : o.email

      [name, qty, o.total]
    end
  end

  def biggest_spenders
    if @current_retailer
    	spenders = @orders.sum(:total, :group => :user_id, :limit => 5, :order => "sum(total) desc", :conditions => "completed_at is not null and user_id is not null")
    else
    	spenders = Spree::Order.sum(:total, :group => :user_id, :limit => 5, :order => "sum(total) desc", :conditions => "completed_at is not null and user_id is not null")
    end
    spenders = spenders.map do |o|
      orders = Spree::User.find(o[0]).orders
      qty = orders.size
      name = @current_retailer ? orders.first.bill_address.try(:full_name) : orders.first.email

      [name, qty, o[1]]

    end

    spenders.sort { |x,y| y[2] <=> x[2] }
  end

end
