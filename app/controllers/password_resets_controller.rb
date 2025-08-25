class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(create edit update)
  before_action :valid_user, :check_expiration, only: %i(edit update)
  before_action :check_password_presence, only: :update

  # A user resetting their password is never logged in.
  skip_before_action :logged_in_user

  def new; end

  def edit; end

  def create
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
    end
    flash[:info] = t(".email_sent")
    redirect_to login_url
  end

  def update
    if @user.update(user_params)
      handle_successful_password_reset
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_user
    # This single method can load the user for all actions.
    email = params[:email] || params.dig(:password_reset, :email)
    @user = User.find_by(email: email.downcase) if email
  end

  def valid_user
    unless @user&.activated? && @user.authenticated?(:reset,
                                                     params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".password_reset_expired")
    redirect_to new_password_reset_url
  end

  def check_password_presence
    return unless user_params[:password].empty?

    @user.errors.add(:password, t(".password_empty"))
    render :edit, status: :unprocessable_entity
  end

  def handle_successful_password_reset
    @user.activate unless @user.activated?
    log_in(@user)
    @user.send_password_changed_email
    flash[:success] = t(".password_reset_success")
    redirect_to @user
  end

  def user_params
    params.require(:user)
          .permit(User::PASSWORD_RESET_ATTRIBUTES)
          .merge(reset_digest: nil)
  end
end
