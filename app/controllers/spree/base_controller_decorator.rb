Spree::BaseController.class_eval do
  before_filter :get_request_http_referer
  
  # create a referral from a session
  def referral_create_from_session(referrible)
    unless referrible.referral
		  if session[:referrer_url]
		    Spree::Referral.create(:referrible => referrible, :http_referrer => session[:referrer_url], :domain => session[:referrer_host])
		  end
    end
  end
  
  def get_request_http_referer
    referrer_url = request.referrer
    Rails.logger.info "================="
    Rails.logger.info referrer_url
    unless referrer_url == "/"
		  unless session[:referrer_url]
		    begin
		    	referrer_host = Domainatrix.parse(referrer_url).domain
		    	referrer_host << ".#{Domainatrix.parse(referrer_url).public_suffix}" unless Domainatrix.parse(referrer_url).public_suffix.blank?
		    	session[:referrer_host] = referrer_host
		    rescue
		    	session[:referrer_host] = nil
		    end
		    if session[:referrer_host] && session[:referrer_host] != request.host
		    	session[:referrer_url] = referrer_url
		    end
		  end    
    end
  end
end
