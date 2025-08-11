class Supervisor::CoursesController < Supervisor::BaseController
  before_action :find_course, only: %i(show members subjects)
  before_action :check_course_access, only: %i(show members subjects)
  before_action :set_courses_page_class
  before_action :check_supervisor_role

  # GET supervisor/courses/:id
  def show
    redirect_to members_course_path @course
  end

  # GET supervisor/courses/:id/members
  def members
    @trainers = @course.supervisors.includes :user_courses
    @pagy, @trainees = pagy(@course.user_courses.trainees,
                            limit: Settings.pagination.course_members_per_page)
    @trainee_count = @pagy.count
    @trainer_count = @trainers.count
    @subject_count = @course.subjects.count
  end

  # GET supervisor/courses/:id/subjects
  def subjects
    @subjects = @course.course_subjects.includes :subject
    @subject_count = @subjects.count
    @trainee_count = @course.trainee_count
  end

  # GET supervisor/courses/new
  def new
    @course = Course.new
    @course.course_subjects.build.build_subject
  end

  # POST supervisor/courses
  def create
    @course = Course.new course_params.merge(user_id: current_user.id)

    if @course.save
      handle_success_creation
    else
      handle_failure_creation
    end
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
    return if current_user.admin?
    return if @course.supervisors.include?(current_user)
    return if @course.users.include?(current_user)

    flash[:danger] = t(".access_denied")
    redirect_to root_path
  end

  def course_params
    params.require(:course).permit Course::COURSE_PARAMS
  end

  def handle_success_creation
    flash[:success] = t(".course_created_successfully")
    redirect_to supervisor_courses_path
  end

  def handle_failure_creation
    flash.now[:danger] = t(".course_creation_failed")
    render :new, status: :unprocessable_entity
  end
end
