class CoursesController < ApplicationController
  before_action :find_course, only: %i(show members subjects)
  before_action :check_course_access, only: %i(show members subjects)
  before_action :set_courses_page_class

  # GET /courses/:id
  def show
    redirect_to members_course_path @course
  end

  # GET /courses/:id/members
  def members
    @trainers = @course.supervisors.includes :user_courses
    @pagy, @trainees = pagy(@course.user_courses.trainees,
                            limit: Settings.pagination.course_members_per_page)
    @trainee_count = @pagy.count
    @trainer_count = @trainers.count
    @subject_count = @course.subjects.count
  end

  # GET /courses/:id/subjects
  def subjects
    @subjects = @course.course_subjects.includes :subject
    @subject_count = @subjects.count
    @trainee_count = @course.trainee_count
  end

  private

  def set_courses_page_class
    self.page_class = Settings.page_classes.courses
  end

  def find_course
    @course = Course.find_by id: params[:id]
    return if @course

    flash[:danger] = t(".course_not_found")
    redirect_to root_path
  end

  def check_course_access
    # Allow access if user is admin, supervisor of the course, or enrolled in
    # the course
    return if current_user.admin?
    return if @course.supervisors.include?(current_user)
    return if @course.users.include?(current_user)

    flash[:danger] = t(".access_denied")
    redirect_to root_path
  end
end
