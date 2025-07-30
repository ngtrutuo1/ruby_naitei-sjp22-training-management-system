class SessionsController < ApplicationController
  before_action :validate_session_params, only: :create

  REMEMBER_ME = "1".freeze

  # GET /login
  def new; end

  # POST /login
  def create
    user = find_user_by_email

    if user.try(:authenticate, session_password)
      handle_successful_login(user)
    else
      handle_failed_login
    end
  end

  # DELETE /logout
  def destroy
    log_out if logged_in?
    flash[:success] = t(".logout_success")
    redirect_to root_path, status: :see_other
  end

  private

  def validate_session_params
    if params.dig(:session, :email).present? &&
       params.dig(:session, :password).present?
      return
    end

    flash.now[:danger] = t(".missing_credentials")
    render :new, status: :unprocessable_entity
  end

  def find_user_by_email
    email = params.dig(:session, :email)&.downcase&.strip
    return nil if email.blank?

    User.find_by(email:)
  end

  def session_password
    params.dig(:session, :password)
  end

  def handle_successful_login user
    reset_session
    log_in(user)
    if params.dig(:session,
                  :remember_me) == REMEMBER_ME
      remember(user)
    else
      create_session(user)
    end
    flash[:success] = t(".login_success")
    redirect_to user_path(user), status: :see_other
  end

  def handle_failed_login
    flash.now[:danger] = t(".login_failed")
    render :new, status: :unprocessable_entity
  end
end
