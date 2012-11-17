module Spree
  module Admin
    class ProductCostsController < ResourceController
      before_filter :load_data #, :only => [:edit, :new, :update, :create]
  
  
      # GET /retailer/1/product_costs
      # GET /retailer/1/product_costs.json
      # Get a list of all products, so we show all variants and cost for the retailer, even if the retailer's cost is not yet set
      def index
        respond_with(@collection) do |format|
          format.html
          format.json { render :json => json_data }
        end
       end
       
       
     # PUT /product_costs/1
     # PUT /product_costs/1.json
      def update
        @product_cost = ProductCost.find(params[:id])

        respond_to do |format|
          if @product_cost.update_attributes(params[:spree_product_cost])
             format.json { head :ok }
          else
            format.json { render json: @product_cost.errors, status: :unprocessable_entity }
          end
        end
      end
       
      # 
      #  # GET /retailer/1/product_costs/1
      #  # GET /retailer/1/product_costs/1.json
      #  def show
      #    @product_cost = ProductCost.find(params[:id])
      # 
      #    respond_to do |format|
      #      format.html # show.html.erb
      #      format.json { render json: @product_cost }
      #    end
      #  end
       
      

      # GET /product_costs/new
      # GET /product_costs/new.json
    #  def new
    #    @retailer = Retailer.new

    #    respond_to do |format|
    #      format.html # new.html.erb
    #      format.json { render json: @retailer }
    #    end
    #  end

      # GET /product_costs/1/edit
    #  def edit
    #    @retailer = Retailer.find(params[:id])
    #  end

      # POST /product_costs
      # POST /product_costs.json
    #  def create
    #    @retailer = Retailer.new(params[:retailer])

    #    respond_to do |format|
    #      if @retailer.save
    #        format.html { redirect_to @retailer, notice: 'Retailer was successfully created.' }
    #        format.json { render json: @retailer, status: :created, location: @retailer }
    #      else
    #        format.html { render action: "new" }
    #        format.json { render json: @retailer.errors, status: :unprocessable_entity }
    #      end
    #    end
    #  end

      # PUT /product_costs/1
      # PUT /product_costs/1.json
    #  def update
    #    @retailer = Retailer.find(params[:id])

    #    respond_to do |format|
    #      if @retailer.update_attributes(params[:retailer])
    #        format.html { redirect_to admin_retailer_url(@retailer), notice: 'Retailer was successfully updated.' }
    #        format.json { head :ok }
    #      else
    #        format.html { render action: "edit" }
    #        format.json { render json: @retailer.errors, status: :unprocessable_entity }
    #      end
    #    end
    #  end

    	protected
    	
      def collection
        return @collection if @collection.present?
        
        unless request.xhr?
          params[:search] ||= {}
          
          params[:search][:meta_sort] ||= "name.asc"
          @search = Spree::Product.not_deleted.metasearch(params[:search])
          
          @collection = @search.relation.group_by_products_id.includes([:master, {:variants => [:images, :option_values]}]).page(params[:page]).per(Spree::Config[:admin_products_per_page])
        else
          includes = [{:variants => [:images,  {:option_values => :option_type}]}, :master, :images]
          
          @collection = Spree::Product.not_deleted.where(["name #{LIKE} ?", "%#{params[:q]}%"])
          @collection = @collection.includes(includes).limit(params[:limit] || 10)
          
          tmp = Spree::Product.not_deleted.where(["#{Variant.table_name}.sku #{LIKE} ?", "%#{params[:q]}%"])
          tmp = tmp.includes(:variants_including_master).limit(params[:limit] || 10)
          @collection.concat(tmp)
          
          @collection.uniq
        end
      end
         	
      private
  
      # Load up retailer
    	def load_data
    	  @retailer = Retailer.find(params[:retailer_id])
      end

    end
  end
end
