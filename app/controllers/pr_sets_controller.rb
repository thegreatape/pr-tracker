class PrSetsController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = "PRs"
    @pr_sets = pr_sets
  end

  def latest
    @title = "Latest PRs"
    @pr_sets = pr_sets.order(date: :desc)
  end

  private

  def pr_sets
    exercises = Exercise.where(benchmark_lift: true)
    current_user
      .exercise_sets
      .pr_sets
      .joins(:exercise, :workout)
      .where(exercise: exercises, latest_pr: true)
      .or(current_user.exercise_sets.where(exercise: {synonym_of: exercises}, latest_pr: true))
  end
end
