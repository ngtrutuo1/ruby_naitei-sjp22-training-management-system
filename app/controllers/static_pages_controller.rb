class StaticPagesController < ApplicationController
  # GET / (root)
  # GET /static_pages/home
  def home
    redirect_to admin_dashboards_path if manager?

    trainee_dashboard
  end

  private
  def trainee_dashboard
    @q = current_user.courses.ransack(params[:q])
    @pagy, @courses = pagy(
      @q.result(distinct: true)
        .ordered_by_start_date
        .includes(:user)
                  .with_attached_image,
      items: Settings.ui.items_per_page
    )
  end
end
