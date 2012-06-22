Spree::ProductsController.class_eval do
	def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products
    if @no_products_found = @products.empty?
    	@searcher = Spree::Config.searcher_class.new(params.delete_if {|key, value| key == "keywords" })
    	@products = @searcher.retrieve_products
    end
    respond_with(@products)
  end
end
