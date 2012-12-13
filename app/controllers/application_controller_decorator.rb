ApplicationController.class_eval do
  
  before_filter :save_referer_and_enable_age_gate_if_google
  
  before_filter :check_age_restriction
  
  protected
  # check if the user has failed the age gate, if so redirect him to the '/pages/age_restriction'
  # cases: not set, passed, failed, 
  # This is the check after the user has been asked to provide his age, and he has either failed to comply or passed.
  # We need to check on all subsequent page views, so that is what this filter is for.
  def check_age_restriction
    if ((session[:age_gate] && session[:age_gate] == 'failed') && !request.path.include?('/pages/age_restriction'))
      redirect_to '/pages/age_restriction'
      false
    else
      true
    end
  end
  
  
  # Capture the referrer on the first page view, so we can enable/disable the age gate based on that
  def save_referer_and_enable_age_gate_if_google
    unless session[:first_referer]
      session[:first_referer] = request.env["HTTP_REFERER"] || 'none'
      session[:enable_age_gate] == true if session[:first_referer].include?('google')
    end
  end
end
