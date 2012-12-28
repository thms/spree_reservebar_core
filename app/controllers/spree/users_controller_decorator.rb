Spree::UsersController.class_eval do
  
  # Change the display order of the orders o the my account page
  def show
    @orders = @user.orders.complete.order("spree_orders.created_at desc")
  end
end
