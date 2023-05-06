class WorkoutsController < ApplicationController
  DEFAULT_DATES_PER_PAGE = 20

  before_action :authenticate_user!

  def index
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
    page_size = params.fetch(:per_page, DEFAULT_DATES_PER_PAGE)
    @dates = (0..page_size).map {|i| start_date - i.days }
    @workouts = current_user.workouts.order(date: :desc).where(date: (@dates.last..@dates.first)).group_by(&:date)

    @prev_page_date = start_date - page_size.days - 1
    @next_page_date = start_date + page_size.days + 1
  end

  def show
    @workout = current_user.workouts.find(params[:id])
  end

  def new
    @workout = current_user.workouts.new(date: params[:date])
  end

  def edit
    @workout = current_user.workouts.find(params[:id])
  end

  def create
    @workout = Workout.create_from_parsed(Parser.new.parse(workout_params[:raw_text]), workout_params[:date], current_user.id)

    PrFinder.update
    @workout.reload

    respond_to do |format|
      format.html { redirect_to workout_path(@workout), notice: "Workout created" }
      format.turbo_stream { flash[:now] = "Workout created" }
    end
  end

  def update
    @workout = current_user.workouts.find(params[:id])
    if @workout.update(workout_params)

      PrFinder.update
      @workout.reload

      respond_to do |format|
        format.html { redirect_to workout_path(@workout), notice: "Workout updated" }
        format.turbo_stream { flash[:now] = "Workout updated" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    workout = current_user.workouts.find(params[:id])
    @date = workout.date
    workout.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: "Workout deleted" }
      format.turbo_stream { flash[:now] = "Workout deleted" }
    end
  end

  def workout_params
    params.require(:workout).permit(:date, :raw_text)
  end
end
