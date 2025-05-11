class ExercisesController < ApplicationController
  def index
    @exercises = current_user.exercises.distinct.where(synonym_of_id: nil).order(:name)
  end

  def search
    @exercise = current_user.exercises.find(params[:exercise_id])
    @search_results = current_user.exercises
      .where("name ILIKE ?", "%#{params[:query]}%")
      .where.not(id: @exercise.id)
      .where.not(id: @exercise.synonyms.pluck(:id))
      .where(synonym_of_id: nil)
      .limit(5)
    
    respond_to do |format|
      format.html { render partial: "search_results" }
      format.turbo_stream { render partial: "search_results" }
    end
  end

  def add_synonym
    @exercise = current_user.exercises.find(params[:id])
    synonym = current_user.exercises.find(params[:synonym_id])
    
    if synonym.update(synonym_of: @exercise)
      redirect_to exercises_path, notice: "#{synonym.name} added as a synonym of #{@exercise.name}"
    else
      redirect_to exercises_path, alert: "Failed to add synonym"
    end
  end
end
