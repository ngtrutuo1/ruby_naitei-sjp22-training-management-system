class Trainee::UserSubjectsController < Trainee::BaseController
  before_action :load_user_subject, only: %i(update)

  USER_SUBJECT_PARAMS = %i(started_at completed_at status).freeze

  # PATCH /trainee/user_subjects/:id
  def update
    flash[:success] = t(".subject_updated") if update?

    redirect_to trainee_courses_path(course_id: @user_subject.course_id)
  end

  private

  def user_subject_params
    params.require(:user_subject)
          .permit(USER_SUBJECT_PARAMS).tap do |whitelisted|
      whitelisted[:status] = whitelisted[:status].to_i if whitelisted[:status]
    end
  end

  def load_user_subject
    @user_subject = current_user.user_subjects.find_by(id: params[:id])
    return if @user_subject

    flash[:danger] = t(".subject_not_found")
    redirect_to trainee_courses_path
  end

  def update?
    return true if @user_subject.update(user_subject_params)

    flash[:danger] = t(".update_failed")
    false
  end
end
