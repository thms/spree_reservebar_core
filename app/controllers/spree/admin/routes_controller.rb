module Spree
  module Admin
    class RoutesController < ResourceController

      respond_to :html

      def index
        respond_with(@collection) do |format|
          format.html
          format.json { render :json => json_data }
        end
      end
       
      protected
      
      def collection
          @product = Product.find_by_permalink(params[:product_id])
          @collection = Route.find_all_by_product_id(@product.id)
      end
     	
    end
  end
end
