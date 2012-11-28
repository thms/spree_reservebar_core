ApplicationController.class_eval do
  before_filter :check_age_restriction
  
  protected
  # check if the user has failed the age gate, if so redirect him to the '/pages/age_restriction'
  # cases: not set, passed, failed, 
  def check_age_restriction
    if ((session[:age_gate] && session[:age_gate] == 'failed') && !request.path.include?('/pages/age_restriction'))
      redirect_to '/pages/age_restriction'
      false
    else
      true
    end
  end
end
