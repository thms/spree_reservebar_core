module Spree
  module Admin
    class CountiesController < ResourceController

      respond_to :html

      def index
        respond_with(@collection) do |format|
          format.html
          format.json { render :json => json_data }
        end
      end
       
      protected
      
      def collection
          @retailer = Retailer.find(params[:retailer_id])
          @collection = Spree::County.find_all_by_state_id(@retailer.physical_address.state_id)
      end
     	
    end
  end
end
