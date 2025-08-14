class Supervisor::UserCoursesController < Supervisor::BaseController
  before_action :load_course
  before_action :load_user_course, only: %i(destroy)

  # DELETE /supervisor/courses/:course_id/user_courses/:id
  def destroy
    if @user_course.destroy
      flash[:success] = I18n.t("courses.destroy_user_course.success")
    else
      flash[:danger] = I18n.t("courses.destroy_user_course.failed")
    end

    redirect_back fallback_location: members_fallback_path
  end

  private

  def load_course
    @course = Course.find_by(id: params[:course_id])
    return if @course

    flash[:danger] = I18n.t("courses.errors.course_not_found")
    redirect_to root_path
  end

  def load_user_course
    @user_course = @course.user_courses
                          .includes(user_subjects: [
                                      :comments,
        {user_tasks: :documents_attachments}
                                    ])
                          .find_by(id: params[:id])
    return if @user_course

    flash[:danger] = I18n.t("courses.errors.user_course_not_found")
    redirect_back fallback_location: members_fallback_path
  end

  def members_fallback_path
    members_supervisor_course_path(@course)
  end
end
