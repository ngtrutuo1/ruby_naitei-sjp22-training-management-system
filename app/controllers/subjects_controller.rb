class SubjectsController < ApplicationController
  # GET /subjects.json
  def index
    @subjects = search_subjects(params[:query], excluded_subject_ids)

    respond_to do |format|
      format.json {render json: build_subjects_json(@subjects)}
    end
  end

  private

  def excluded_subject_ids
    return [] if params[:course_id].blank?

    Course.find(params[:course_id]).subjects.pluck(:id)
  rescue ActiveRecord::RecordNotFound
    []
  end

  def search_subjects query, excluded_ids
    Subject.includes(:tasks)
           .where.not(id: excluded_ids)
           .search_by_name(query)
           .ordered_by_name
           .limit(Settings.ui_limits.subject_search_limit)
  end

  def build_subjects_json subjects
    subjects.map do |subject|
      {
        id: subject.id,
        name: subject.name,
        estimated_time_days: subject.estimated_time_days,
        max_score: subject.max_score,
        tasks: subject.tasks.map {|task| {id: task.id, name: task.name}},
        task_names: subject.tasks.pluck(:name)
      }
    end
  end
end
