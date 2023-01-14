class WorkoutsController < ApplicationController
  DEFAULT_DATES_PER_PAGE = 20

  def index
    @workouts = Workout.order(date: :desc).page(params[:page])
  end

  def by_date
    start_date = Date.parse(params.fetch(:start_date, Date.today))
    @dates = (0..params.fetch(:per_page, DEFAULT_DATES_PER_PAGE)).map {|i| start_date - i.days }.reverse
    @workouts = Workout.order(date: :desc).where(date: (@dates.first..@dates.last)).group_by(&:date)
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
