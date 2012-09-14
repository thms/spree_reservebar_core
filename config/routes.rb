Spree::Core::Engine.routes.prepend do
  
  namespace :admin do
    
    match '/get_retailer_data' => 'overview#get_retailer_data'
    match '/orders/get_retailer_data' => 'orders#get_retailer_data'
    resources :retailers do
      get :activate
      get :suspend
      put :update_shipping
      resources :product_costs
    end

    
    resources :orders do
      member do
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
    end

    # Add a route to print a test label for the shipping methods
    resources :shipping_methods do
      get :print_test_label
    end


  end
end
