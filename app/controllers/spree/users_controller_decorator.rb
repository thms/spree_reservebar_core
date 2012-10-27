Spree::UsersController.class_eval do
	def show
    @orders = @user.orders.complete.order("spree_orders.created_at desc")
  end
end
