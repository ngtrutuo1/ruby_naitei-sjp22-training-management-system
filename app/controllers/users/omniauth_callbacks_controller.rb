# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_google_auth(request.env["omniauth.auth"])
  end

  private

  def handle_google_auth auth
    @user = User.from_omniauth(auth)
    if @user.persisted?
      handle_successful_auth
    else
      handle_failed_auth(auth)
    end
  end

  def handle_successful_auth
    flash[:notice] = t("devise.omniauth_callbacks.success", kind: "Google")
    sign_in_and_redirect @user, event: :authentication
  end

  def handle_failed_auth auth
    session["devise.google_data"] = auth.except(:extra)
    redirect_to new_user_registration_url,
                alert: @user.errors.full_messages.join("\n")
  end

  def failure
    flash[:alert] = t("sessions.google_auth_failed")
    redirect_to root_path
  end
end
