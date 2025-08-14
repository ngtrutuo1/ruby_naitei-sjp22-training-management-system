class Supervisor::CategoriesController < Supervisor::BaseController
  before_action :load_category, only: %i(destroy)

  # GET /supervisor/categories
  def index
    @pagy, @categories = pagy Category.includes(:subjects)
                                      .search_by_name(params[:search]),
                              items: Settings.ui.items_per_page
  end

  # DELETE /supervisor/categories/:id
  def destroy
    if @category.destroy
      flash[:success] = t(".category_deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to supervisor_categories_path
  end

  private

  def load_category
    @category = Category.includes(:subject_categories).find_by id: params[:id]
    return if @category

    flash[:danger] = t("not_found_category")
    redirect_to supervisor_categories_path
  end
end
