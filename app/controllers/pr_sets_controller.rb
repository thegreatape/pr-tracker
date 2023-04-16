class PrSetsController < ApplicationController
  before_action :authenticate_user!

  BENCHMARK_LIFTS = [
    "Bench Press",
    "Deadlift",
    "Front Squat",
    "Overhead Press",
    "Safety Bar Squat",
    "Squat",
    "Trap Bar Deadlift",
    "Log",
    "Romanian Deadlift"
  ]

  def index
    @title = "PRs"

    @pr_sets = current_user.exercise_sets.pr_sets.joins(:exercise, :workout).where(exercise: {name: BENCHMARK_LIFTS}, latest_pr: true)
  end

  def latest
    @title = "Latest PRs"

    @pr_sets = current_user.exercise_sets.pr_sets.joins(:exercise, :workout).where(exercise: {name: BENCHMARK_LIFTS}).order(date: :desc)
  end
end
