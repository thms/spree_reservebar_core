class Spree::AbilityDecorator
	include CanCan::Ability
 
	def initialize(user)

	  if user.has_role? 'retailer'
	    can :index, :overview
	    can :admin, :overview
	    	    
	    can :manage, Spree::Order do |order|
	      (order.retailer_ids & user.retailer_ids).present?
	    end
	    
	    can :manage, :customer_details
	    
	    can :manage, Spree::Adjustment do |adjustment|
	      adjustment.order.retailer_id == user.retailer_id
	    end

	    can :manage, Spree::Payment do |payment|
	      payment.order.retailer_id == user.retailer_id
	    end

	    can :manage, Spree::Shipment do |shipment|
	      shipment.order.retailer_id == user.retailer_id
	    end

	    can :manage, Spree::ShipmentDetail do |shipment_detail|
	      shipment_detail.order.retailer_id == user.retailer_id
	    end

	    can :manage, Spree::ReturnAuthorization do |return_authorization|
	      return_authorization.order.retailer_id == user.retailer_id
	    end
	    
	    # reference: https://github.com/ryanb/cancan/wiki/Non-RESTful-Controllers
	    can :index, :reports
	    can :sales_total, :reports
	    can :admin, :reports
	    
	    
	    
	  end
	  
	  # enable access to FedexLabels for non-logged until we figure out a way to 
	  # send the session cookie with the request from the jZebra applet. (Or use tokenized resource for this ..)
	  # Todo: probably also need to grant access to create the label for retailers.
	  can :print_label, Spree::ShipmentDetail do |shipment_detail, token|
	    shipment_detail.token && token == shipment_detail.token
	  end

	  can :print_test_label, :shipping_methods

	end
end

Spree::Ability.register_ability(Spree::AbilityDecorator)
