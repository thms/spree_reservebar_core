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
      resources :shipments do
        resources :shipment_details do
          post :create
          get  :print_label
        end
      end
    end

    # Add a route to prnt a test label for the shipping methods
    resources :shipping_methods do
      get :print_test_label
    end


  end
end
