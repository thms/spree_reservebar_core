Spree::Admin::ProductsController.class_eval do
  
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

          @collection = super.where(["name #{LIKE} ? and deleted_at is ?", "%#{params[:q]}%", nil])
          @collection = @collection.includes(includes).limit(params[:limit] || 10)

          tmp = super.where(["#{Spree::Variant.table_name}.sku #{LIKE} ?", "%#{params[:q]}%"])
          tmp = tmp.includes(:variants_including_master).limit(params[:limit] || 10)
          @collection.concat(tmp)

          @collection.uniq
        end

      end

end
