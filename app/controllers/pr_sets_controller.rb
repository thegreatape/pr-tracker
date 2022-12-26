class PrSetsController < ApplicationController
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

    @pr_sets = PrSet.joins(:exercise).where(exercise: {name: BENCHMARK_LIFTS}, latest: true)
  end

  def latest
    @title = "Latest PRs"

    @pr_sets = PrSet.joins(:exercise).where(exercise: {name: BENCHMARK_LIFTS}).order(date: :desc)
  end
end
