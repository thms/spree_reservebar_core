module Spree::Search
	class ReservebarSearch < Spree::Core::Search::Base

    def retrieve_products
      base_scope = get_base_scope
      @products_scope = @product_group.apply_on(base_scope)
      curr_page = manage_pagination && keywords ? 1 : page

      @products = @products_scope.includes([:images, :master, :taxons]).page(curr_page).per(per_page)
    end

		# method should return new scope based on base_scope
		def get_products_conditions_for(base_scope, query)
			base_scope.rlike_any_or_in_taxons([:name], query.split)
		end

	end
end
