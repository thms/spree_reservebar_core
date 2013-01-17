Spree::Admin::BaseController.class_eval do
  before_filter :authorize_admin
  
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.warn "Access denied on #{exception.action} #{exception.subject.inspect}"
  end

  def authorize_admin
    begin
      model = model_class
    rescue
      #model = Object
      # change the Object to controller_name.to_sym
      # Reference here: https://github.com/ryanb/cancan/wiki/Non-RESTful-Controllers
      model = controller_name.to_sym
    end
    authorize! :admin, model
    authorize! params[:action].to_sym, model
  end

  protected
    def model_class
      "Spree::#{controller_name.classify}".constantize
    end
end
