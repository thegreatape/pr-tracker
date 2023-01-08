class WorkoutsController < ApplicationController
  def index
    @workouts = Workout.order(date: :desc).page(params[:page])
  end

  def show
    @workout = Workout.find(params[:id])
  end

  def edit
    @workout = Workout.find(params[:id])
  end

  def update
    @workout = Workout.find(params[:id])
    if @workout.update(params.require(:workout).permit(:date, :raw_text))
      redirect_to workout_path(@workout), notice: "Workout updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
