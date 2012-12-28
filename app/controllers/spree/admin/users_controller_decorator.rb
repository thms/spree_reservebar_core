Spree::Admin::UsersController.class_eval do

	before_filter :load_retailers, :only => [:edit, :new, :update, :create]

  create.after :save_retailer
  update.before :save_retailer
  
  
  def export
    @users = Spree::User.registered
  end

  def export
    @users = Spree::User.registered
  end
  
  protected
  
  def save_retailer
    return unless params[:user]
    return unless @user.respond_to?(:retailer_id)
    if params[:user][:retailer_id].present?
    	retailer = Spree::Retailer.find(params[:user][:retailer_id])
    	@user.retailer = retailer
		else
			@user.retailer = nil
		end
    #params[:user].delete(:retailer_id)
  end

#  def save_user_retailers
#    return unless params[:user]
#    return unless @user.respond_to?(:retailers)
#    @user.retailers.delete_all
#    params[:user][:retailer] ||= {}
#    Retailer.all.each { |retailer|
#      @user.retailers << retailer unless params[:user][:retailer][retailer.id.to_s].blank?
#    }
#    params[:user].delete(:retailer)
#  end

	private
	
	def load_retailers
    @retailers = Spree::Retailer.all
  end
end
