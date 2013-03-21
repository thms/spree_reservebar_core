Spree::Admin::ProductsController.class_eval do
  
  
  # View the final routes after all routing decisions have been made
  def routes
    @product = ::Spree::Product.find_by_permalink(params[:product_id])
  end
  # Edit the routing assignment
  def edit_routes
    @product = ::Spree::Product.find_by_permalink(params[:product_id])
    @collection = ::Spree::Route.find_all_by_product_id(@product.id)
  end
  
  # Sends the routing information for all active retailers
  # {routes => {"1" => "preferred", "2" => 'last_resort'}}
  def update_routes
    @product = ::Spree::Product.find_by_permalink(params[:product_id])
    @routes = params[:routes]
    @routes.each do |retailer_id, value|
      if Spree::Route.exists?(:product_id => @product.id, :retailer_id => retailer_id)
        Spree::Route.where(:product_id => @product.id, :retailer_id => retailer_id).first.update_attribute(:route, value)
      else
        Spree::Route.create(:product_id => @product.id, :retailer_id => retailer_id, :route => value)
      end
    end
    flash[:notice] = "Routes for this product have been updated"
    redirect_to admin_product_routes_url(@product)
  end
  
  protected
  
      def collection
        return @collection if @collection.present?

        unless request.xhr?
          params[:search] ||= {}
          # Note: the MetaSearch scopes are on/off switches, so we need to select "not_deleted" explicitly if the switch is off
          if params[:search][:deleted_at_is_null].nil?
            params[:search][:deleted_at_is_null] = "1"
          end

          params[:search][:meta_sort] ||= "name.asc"
          @search = super.metasearch(params[:search])

          @collection = @search.relation.group_by_products_id.includes([:master, {:variants => [:images, :option_values]}]).page(params[:page]).per(Spree::Config[:admin_products_per_page])
        else
          includes = [{:variants => [:images,  {:option_values => :option_type}]}, :master, :images]

          @collection = super.active.where(["name #{LIKE} ?", "%#{params[:q]}%"])
          @collection = @collection.includes(includes).limit(params[:limit] || 10)

          tmp = super.active.where(["#{Spree::Variant.table_name}.sku #{LIKE} ?", "%#{params[:q]}%"])
          tmp = tmp.includes(:variants_including_master).limit(params[:limit] || 10)
          @collection.concat(tmp)

          @collection.uniq
        end

      end

end
