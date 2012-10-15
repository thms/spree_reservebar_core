module Spree
	class Referral < ActiveRecord::Base
		belongs_to :referrible, :polymorphic => true
		
		def referrible_str
			case referrible_type
			when "Spree::Order" then "Spree::Order #{referrible.number}"
			else
				"#{referrible_type} #{referrible_id}"
			end
		end

		def admin_referrible_path
			case referrible_type
			when "Spree::Order" then "/admin/orders/#{referrible.number}"
			else
				"/admin/#{referrible_type.split('::')[1].downcase.pluralize}/#{referrible_id}"
			end
		end
		
	end
end
