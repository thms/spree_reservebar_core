Spree::Core::Engine.routes.prepend do
  
  namespace :admin do
    
    match '/get_retailer_data' => 'overview#get_retailer_data'
    match '/orders/get_retailer_data' => 'orders#get_retailer_data'
    resources :retailers

    resources :orders do
      resources :shipments do
        resources :shipment_details do
          post :create
          get  :print_label
        end
      end
  end

end




end
