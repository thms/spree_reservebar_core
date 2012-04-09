module Spree
  module Admin
    class RetailersController < ResourceController
      before_filter :load_data, :only => [:edit, :new, :update, :create]
  
      create.after :save_retailer_tax_rates
      update.before :save_retailer_tax_rates
  
      # GET /retailers
      # GET /retailers.json
      def index
        respond_with(@collection) do |format|
          format.html # index.html.erb
          format.json { render json: @retailers }
        end
      end

      # GET /retailers/1
      # GET /retailers/1.json
      def show
        @retailer = Retailer.find(params[:id])

        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @retailer }
        end
      end

      # GET /retailers/new
      # GET /retailers/new.json
    #  def new
    #    @retailer = Retailer.new

    #    respond_to do |format|
    #      format.html # new.html.erb
    #      format.json { render json: @retailer }
    #    end
    #  end

      # GET /retailers/1/edit
    #  def edit
    #    @retailer = Retailer.find(params[:id])
    #  end

      # POST /retailers
      # POST /retailers.json
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

      # PUT /retailers/1
      # PUT /retailers/1.json
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

      # DELETE /retailers/1
      # DELETE /retailers/1.json
      def destroy
        @retailer = Retailer.find(params[:id])
        @retailer.destroy

        respond_to do |format|
          format.html { redirect_to admin_retailers_url }
          format.json { head :ok }
        end
      end

    	protected
	
    	def collection
        return @collection if @collection.present?

        unless request.xhr?
          @search = Retailer.metasearch(params[:search])
          @collection = @search.relation.page(params[:page]).per(Spree::Config[:admin_products_per_page])
        else
          #disabling proper nested include here due to rails 3.1 bug
          #@collection = User.includes(:bill_address => [:state, :country], :ship_address => [:state, :country]).
          @collection = Retailer.includes(:physical_address, :mailing_address, :payment_method).
                            where("retailers.name #{LIKE} :search",
                                   {:search => "#{params[:q].strip}%"}).
                            limit(params[:limit] || 100)
        end

      end
  
      def save_retailer_tax_rates
        return unless params[:retailer]
        return unless @retailer.respond_to?(:tax_rates)
        @retailer.tax_rates.delete_all
        params[:retailer][:tax_rate] ||= {}
        TaxRate.all.each { |tax_rate|
          @retailer.tax_rates << tax_rate unless params[:retailer][:tax_rate][tax_rate.id.to_s].blank?
        }
        params[:retailer].delete(:tax_rate)
      end
  
      private
  
    	def load_data
        @payment_methods = PaymentMethod.order(:name)
        @tax_rates = TaxRate.all
        @object.physical_address ||= Address.new(:country_id => 214, :firstname => "retailer", :lastname => "retailer", :phone => "phone")
        @object.mailing_address ||= Address.new(:country_id => 214, :firstname => "retailer", :lastname => "retailer", :phone => "phone")
        @object
      end

    end
  end
end