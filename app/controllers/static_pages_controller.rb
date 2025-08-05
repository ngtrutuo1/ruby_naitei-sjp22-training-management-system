class StaticPagesController < ApplicationController
  # GET / (root)
  # GET /static_pages/home
  def home
    return unless logged_in?

    @pagy, @courses = pagy(
      current_user.courses
                  .by_status(params[:status])
                  .ordered_by_start_date,
      items: Settings.ui.items_per_page
    )
  end

  private
  def trainee_dashboard
    @pagy, @courses = pagy(
      current_user.courses.by_status(params[:status]).ordered_by_start_date,
      items: Settings.ui.items_per_page
    )
  end

  def manager_dashboard
    load_overview_metrics
    load_active_courses
  end

  def load_overview_metrics
    @trainer_count = User.supervisor.count
    @trainee_count = User.trainee.count
    @active_courses_count = Course.in_progress.count
    total_courses = Course.count.to_f
    @completion_rate =
      if total_courses.zero?
        Setting.completion_rate.zero
      else
        (Course.finished.count / total_courses * Settings.percentage).round
      end
  end

  def load_active_courses
    base_query = Course.includes(:user)
    final_query = base_query.search_by_name(params[:search])
                            .ordered_by_start_date
    @pagy, @courses = pagy(final_query,
                           items: Settings.ui.items_per_page)
    load_course_counts
  end

  def load_course_counts
    return if @courses.blank?

    course_ids = @courses.map(&:id)
    @trainee_counts = UserCourse.where(course_id: course_ids)
                                .group(:course_id).count
    @trainer_counts = CourseSupervisor.where(course_id: course_ids)
                                      .group(:course_id).count
  end
end
