class PrSetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = "PRs"
    @pr_sets = pr_sets(only_latest_pr: true)
  end

  def latest
    @title = "Latest PRs"
    @pr_sets = pr_sets(only_latest_pr: false).order(date: :desc)
  end

  private

  def pr_sets(only_latest_pr:)
    exercises = params[:exercise_id] ? Exercise.where(id: params[:exercise_id]) : Exercise.where(benchmark_lift: true)
    query = current_user
      .exercise_sets
      .pr_sets
      .joins(:exercise, :workout)
      .where(exercise: exercises)
      .or(current_user.exercise_sets.where(exercise: {synonym_of: exercises}))

    if only_latest_pr
      query = query.where(latest_pr: true)
    end

    query
  end
end
