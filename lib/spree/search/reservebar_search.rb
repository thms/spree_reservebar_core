module Spree::Search
	class ReservebarSearch < Spree::Core::Search::Base

		# method should return new scope based on base_scope
		def get_products_conditions_for(base_scope, query)
			base_scope.like_any([:name], query.split)
		end

	end
end
