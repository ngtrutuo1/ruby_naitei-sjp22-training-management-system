class Supervisor::BaseController < ApplicationController
  before_action :check_supervisor_role

  def check_supervisor_role
    return if current_user&.supervisor? || current_user&.admin?

    flash[:danger] = t("messages.permission_denied")
    redirect_to root_path
  end
end
