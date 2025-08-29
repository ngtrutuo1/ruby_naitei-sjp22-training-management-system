class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i(home)
  # GET / (root)
  # GET /static_pages/home
  def home
    if user_signed_in?
      redirect_to admin_dashboards_path if manager?

      @q = Course.accessible_by(current_ability)
                 .ordered_by_start_date
                 .includes(:user)
                 .ransack(params[:q])

      @pagy, @courses = pagy(@q.result(distinct: true))
    else
      redirect_to new_user_session_path
    end
  end
end
