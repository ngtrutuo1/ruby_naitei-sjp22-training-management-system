class Supervisor::SupervisorsController < ApplicationController
  before_action :authorize_supervisor!
  before_action :load_course
  before_action :load_supervisor, only: %i(destroy)

  # DELETE /supervisor/courses/:course_id/supervisors/:id
  def destroy
    if @course.supervisors.destroy(@supervisor)
      flash[:success] = I18n.t("courses.destroy_supervisor.success")
    else
      flash[:danger] = I18n.t("courses.destroy_supervisor.failed")
    end
    redirect_back fallback_location: members_supervisor_course_path(@course)
  end

  private

  def load_course
    @course = Course.find_by(id: params[:course_id])
    return if @course

    flash[:danger] = I18n.t("courses.errors.course_not_found")
    redirect_to root_path
  end

  def load_supervisor
    @supervisor = @course.supervisors.find_by(id: params[:id])
    return if @supervisor

    flash[:danger] = I18n.t("courses.errors.supervisor_not_found")
    redirect_back fallback_location: members_supervisor_course_path(@course)
  end

  def authorize_supervisor!
    return if current_user&.admin? || current_user&.supervisor?

    flash[:danger] = I18n.t("courses.errors.access_denied")
    redirect_to root_path
  end
end
