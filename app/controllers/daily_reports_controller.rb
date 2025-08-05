class DailyReportsController < ApplicationController
  before_action :check_user_role, only: %i(new create)
  # GET /daily_reports/new
  def new
    @daily_report = DailyReport.new
  end

  # POST /daily_reports
  def create
    @daily_report = DailyReport.new daily_report_params
                    .merge(user_id: current_user.id)
    case params[:commit].strip
    when Settings.daily_report.status.draft.to_s
      save_as_draft
    when Settings.daily_report.status.submitted.to_s
      submit_report
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def daily_report_params
    params.require(:daily_report).permit DailyReport::DAILY_REPORT_PARAMS
  end

  def save_as_draft
    @daily_report.status = Settings.daily_report.status.draft
    if @daily_report.save
      flash[:success] = t(".draft_success")
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def submit_report
    @daily_report.status = Settings.daily_report.status.submitted
    if @daily_report.save
      flash[:success] = t(".submit_success")
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def check_user_role
    return if current_user&.trainee?

    flash[:danger] = t("messages.permission_denied")
    redirect_to root_path
  end
end
