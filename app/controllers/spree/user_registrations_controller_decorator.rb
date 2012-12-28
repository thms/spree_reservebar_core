Spree::UserRegistrationsController.class_eval do
  # POST /resource/sign_up
  def create
    @user = build_resource(params[:user])
    if resource.save
      set_flash_message(:notice, :signed_up)
      sign_in(:user, @user)
      fire_event('spree.user.signup', :user => @user)
      referral_create_from_session(@user)
      sign_in_and_redirect(:user, @user)
    else
      clean_up_passwords(resource)
      render_with_scope(:new)
    end
  end
end
