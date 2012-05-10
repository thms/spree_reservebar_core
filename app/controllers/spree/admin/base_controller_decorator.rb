Spree::Admin::BaseController.class_eval do
  #before_filter :authorize_admin

#  def authorize_admin
#    begin
#      model = controller_name.classify.constantize
#    rescue
#      #model = Object
#      # change the Object to controller_name.to_sym
#      # Reference here: https://github.com/ryanb/cancan/wiki/Non-RESTful-Controllers
#      model = controller_name.to_sym
#    end
#    authorize! :admin, model
#    authorize! params[:action].to_sym, model
#  end
end
