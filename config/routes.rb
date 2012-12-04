Spree::Core::Engine.routes.prepend do
  
  
  # route to allow applying a coupon during checkout via Ajax
  match '/checkout/apply_coupon/:state' => 'checkout#apply_coupon', :as => :apply_coupon_checkout
  
  # age gate routes
  match '/age_gate/validate_age' => 'age_gate#validate_age', :as => :age_gate_validate_age
  
  namespace :admin do
    
    resources :age_gates
    
    match '/get_retailer_data' => 'overview#get_retailer_data'
    match '/orders/get_retailer_data' => 'orders#get_retailer_data'
    resources :retailers do
      get :activate
      get :suspend
      put :update_shipping
      resources :product_costs
      get :regular_reminder_email
    end

    
    resources :orders do
      member do
      	get :order_complete
      	get :accept
      	get :confirm_email
      	get :giftor_delivered_email
      	get :giftee_notify_email
      	get :giftee_shipped_email
      	get :giftor_shipped_email
      	get :retailer_submitted_email
      	get :summary
      end
      resources :shipments do
        resources :shipment_details do
          post :create
          get  :print_label
        end
      end
      resources :gifts do
        get :print_card
      end
      collection do
      	get :regular_reminder_email
      	get :export
      end
    end

    # Add a route to print a test label for the shipping methods
    resources :shipping_methods do
      get :print_test_label
    end


  end
end
