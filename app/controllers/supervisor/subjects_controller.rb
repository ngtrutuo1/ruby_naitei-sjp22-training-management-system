class Supervisor::SubjectsController < Supervisor::BaseController
  before_action :load_subject, only: %i(destroy)

  # GET /supervisor/subjects
  def index
    @pagy, @subjects = pagy Subject.includes(:tasks)
                                   .recent
                                   .search_by_name(params[:search]),
                            items: Settings.ui.items_per_page
  end

  # DELETE /supervisor/subjects/:id
  def destroy
    if @subject.destroy
      flash[:success] = t(".subject_deleted")
    else
      flash[:danger] = t(".delete_failed")
    end
    redirect_to supervisor_subjects_path
  end

  # GET /supervisor/subjects/new
  def new
    @subject = Subject.new
  end

  # POST /supervisor/subjects
  def create
    @subject = Subject.new subject_params

    if @subject.save
      flash[:success] = t(".create_success")
      redirect_to supervisor_subjects_path
    else
      flash.now[:danger] = t(".create_fail")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def subject_params
    params.require(:subject).permit Subject::SUBJECT_PERMITTED_PARAMS
  end

  def load_subject
    @subject = Subject.find_by id: params[:id]
    return if @subject

    flash[:danger] = t("not_found_subject")
    redirect_to supervisor_subjects_path
  end
end
