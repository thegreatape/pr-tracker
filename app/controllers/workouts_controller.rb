class WorkoutsController < ApplicationController
  def index
    @workouts = Workout.order(date: :desc).page(params[:page])
  end
end
