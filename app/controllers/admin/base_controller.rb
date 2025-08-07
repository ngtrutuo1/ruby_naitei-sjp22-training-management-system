class Admin::BaseController < ApplicationController
  before_action :check_admin_role

  def check_admin_role
    return if current_user&.admin?

    flash[:danger] = t("messages.permission_denied")
    redirect_to root_path
  end
end
