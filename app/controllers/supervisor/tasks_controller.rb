class Supervisor::TasksController < Supervisor::BaseController
  before_action :load_task, only: %i(destroy)

  # GET /supervisor/tasks
  def index
    @pagy, @tasks = pagy Task.for_taskable_type(Subject.name)
                             .includes(:taskable)
                             .search_by_name(params[:search]),
                         items: Settings.ui.items_per_page
  end

  # DELETE /supervisor/tasks/:id
  def destroy
    if @task.destroy
      flash[:success] = t(".task_deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to supervisor_tasks_path
  end

  private

  def load_task
    @task = Task.find_by id: params[:id]
    return if @task

    flash[:danger] = t("not_found_task")
    redirect_to supervisor_tasks_path
  end
end
