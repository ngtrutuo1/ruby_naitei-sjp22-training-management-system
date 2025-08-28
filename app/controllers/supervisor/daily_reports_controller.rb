class Supervisor::DailyReportsController < Supervisor::BaseController
  # GET supervisor/daily_reports
  authorize_resource
  def index
    @q = DailyReport.accessible_by(current_ability).ransack(params[:q])

    all_reports = @q.result(distinct: true).includes(DailyReport::EAGER_LOADING_PARAMS).recent

    @pagy, @daily_reports = pagy(all_reports)
  end

  # GET supervisor/daily_reports/:id
  def show
    @daily_report = DailyReport.submitted.find_by(id: params[:id],
                                                  course_id: current_user
                                                  .supervised_courses
                                                  .pluck(:id))
    return if @daily_report

    flash[:danger] = t(".report_not_found")
    redirect_to supervisor_daily_reports_path
  end
end
