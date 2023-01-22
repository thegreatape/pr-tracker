class WorkoutsController < ApplicationController
  DEFAULT_DATES_PER_PAGE = 20

  def index
    @workouts = Workout.order(date: :desc).page(params[:page])
  end

  def by_date
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
    page_size = params.fetch(:per_page, DEFAULT_DATES_PER_PAGE)
    @dates = (0..page_size).map {|i| start_date - i.days }
    @workouts = Workout.order(date: :desc).where(date: (@dates.last..@dates.first)).group_by(&:date)

    @prev_page_date = start_date - page_size.days - 1
    @next_page_date = start_date + page_size.days + 1
  end

  def show
    @workout = Workout.find(params[:id])
  end

  def new
    @workout = Workout.new(date: params[:date])
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
