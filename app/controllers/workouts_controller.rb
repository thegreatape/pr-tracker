class WorkoutsController < ApplicationController
  def index
    @workouts = Workout.order(date: :desc)
  end
end
