module Spree
	class AbilityDecorator
		include CanCan::Ability
	 
		def initialize(user)
		  user ||= User.new

		  if user.has_role? 'retailer'
		    can :index, :overview
		    can :admin, :overview
		    
		    can :manage, Order do |order|
		      #(order.retailer_ids & user.retailer_ids).present?
		      order.retailer_id == user.retailer_id
		    end

		    can :manage, Adjustment do |adjustment|
		      adjustment.order.retailer_id == user.retailer_id
		    end

		    can :manage, Payment do |payment|
		      payment.order.retailer_id == user.retailer_id
		    end

		    can :manage, Shipment do |shipment|
		      shipment.order.retailer_id == user.retailer_id
		    end

		    can :manage, ReturnAuthorization do |return_authorization|
		      return_authorization.order.retailer_id == user.retailer_id
		    end
		    
		    # TODO: Check if we want the retailer to do any of these:
		    can :index, Product
		    can :admin, Product
		    can :index, OptionType
		    can :admin, OptionType
		    can :index, Prototype
		    can :admin, Prototype
		    can :index, Property
		    can :admin, Property
		    can :index, ProductGroup
		    can :admin, ProductGroup
		    
		    # reference: https://github.com/ryanb/cancan/wiki/Non-RESTful-Controllers
		    can :index, :reports
		    can :sales_total, :reports
		    can :admin, :reports
		    
		  end
		  
		  # enable access to FedexLabels for non-logged until we figure out a way to 
		  # send the session cookie with the request from the jZebra applet. (Or use tokenized resource for this ..)
		  # Todo: probably also need to grant access to create the label for retailers.
		  can :print_label, ShipmentDetail do |shipment_detail, token|
		    shipment_detail.token && token == shipment_detail.token
		  end
		end
	end
	
	Ability.register_ability(AbilityDecorator)
end
