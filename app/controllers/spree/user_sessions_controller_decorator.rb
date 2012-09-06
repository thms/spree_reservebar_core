# Purpose: after the user logs in, he shold be redirected to the home page instead of the product page, unless there is a redirect location stored.
Spree::UserSessionsController.class_eval do
  def create
    authenticate_user!

    if user_signed_in?
      respond_to do |format|
	      format.html {
	        flash.notice = t(:logged_in_succesfully)
	        if current_user.has_role?("retailer")
	        	redirect_to admin_orders_url
	        else
	        	redirect_back_or_default(root_path)
	        end
	      }
	      format.js {
	        user = resource.record
	        render :json => {:ship_address => user.ship_address, :bill_address => user.bill_address}.to_json
	      }
      end
    else
      flash.now[:error] = t('devise.failure.invalid')
      render :new
    end
  end
end
