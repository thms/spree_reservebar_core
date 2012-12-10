# Perform checks on the user's birth date to limit access to pages for under age people
# Stores result of check in the session
class Spree::AgeGateController < Spree::BaseController
  
  
  ## skip_before_filter :age_gate_validation
  
  #
  def validate_age
    if params['commit'] && params['commit'] == 'Yes'
      session[:age_gate] = "passed"
      redirect_to request.referrer
    else
      #test failed, block session and redirect to we're sorry page
      session[:age_gate] = "failed"
      redirect_to '/pages/age_restriction'
    end
  end
  
  # Deprecated version, where the user had to enter his actual birthdate, too clunky
  # POST /age_gate/validate_age
  # Params: birthdate
  def validate_age_birthdate
    
    if params[:age_gate]['birthdate(1i)'].present?
      birthdate = Date.new(params[:age_gate]['birthdate(1i)'].to_i, params[:age_gate]['birthdate(2i)'].to_i, params[:age_gate]['birthdate(3i)'].to_i)
      if age(birthdate) > 20
        #test passed, let him through
        session[:age_gate] = "passed"
        redirect_to request.referrer
      else
        #test failed, block session and redirect to we're sorry page
        session[:age_gate] = "failed"
        redirect_to '/pages/age_restriction'
      end
    else
    flash[:error] = "Please provide your birth date again."
    redirect_back_or_default '/'
    end
  end
  
  protected
  def age(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end
  
end