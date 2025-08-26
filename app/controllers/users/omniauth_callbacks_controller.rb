class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      if is_navigational_format?
        set_flash_message(:notice, :success,
                          kind: "Google")
      end
    else
      session["devise.google_data"] =
        request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url,
                  alert: t(".devise.omniauth_callbacks
                  .google_oauth2.google_auth_failed")
    end
  end
end
