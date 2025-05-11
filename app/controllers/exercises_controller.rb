class ExercisesController < ApplicationController
  def index
    @exercises = current_user.exercises.distinct.where(synonym_of_id: nil).order(:name)
  end

  def search
    @exercise = current_user.exercises.find(params[:exercise_id])
    @search_results = current_user.search_exercises(params[:query], exclude_exercise: @exercise)
    
    render partial: "search_results", locals: { search_results: @search_results, exercise: @exercise }
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

  def unlink_synonym
    @exercise = current_user.exercises.find(params[:id])
    synonym = current_user.exercises.find(params[:synonym_id])
    
    if @exercise.unlink_synonym(synonym)
      redirect_to exercises_path, notice: "#{synonym.name} unlinked from #{@exercise.name}"
    else
      redirect_to exercises_path, alert: "Failed to unlink synonym"
    end
  end
end
