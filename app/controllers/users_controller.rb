class UsersController < ApplicationController
  before_action :load_user, only: :show

  # GET /users/:id
  def show; end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new(user_params)

    if @user.save
      handle_successful_signup
    else
      handle_failed_signup
    end
  end

  private

  def handle_successful_signup
    reset_session
    log_in(@user)
    create_session(@user)
    set_success_flash_and_redirect
  end

  def handle_failed_signup
    render :new, status: :unprocessable_entity
  end

  def set_success_flash_and_redirect
    flash[:success] = t(".signup_success")
    redirect_to user_path(@user), status: :see_other
  end

  def user_params
    params.require(:user).permit User::PERMITTED_ATTRIBUTES
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:danger] = t(".user_not_found")
    redirect_to root_path
  end
end
