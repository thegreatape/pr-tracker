require 'pr_finder'
require 'date'
require 'parser'
require 'exercise'

describe PRFinder do
  it "reports rep PRs over time" do
    last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Deadlift
    265x5x3
    WORKOUT
    last_week_workout = Parser.new.parse(last_week_workout_text, last_week)

    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    270x5x3
    WORKOUT
    yesterday_workout = Parser.new.parse(yesterday_workout_text, yesterday)

    today = Date.today
    today_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    today_workout = Parser.new.parse(today_workout_text, today)

    prs = PRFinder.new([last_week_workout, yesterday_workout, today_workout]).prs
    expect(prs.length).to eq(2)

    expect(prs.first.exercise.name).to eq("Deadlift")
    expect(prs.first.reps).to eq(5)
    expect(prs.first.weight_lbs).to eq(270)
    expect(prs.first.date).to eq(yesterday)

    expect(prs.last.exercise.name).to eq("Deadlift")
    expect(prs.last.reps).to eq(3)
    expect(prs.last.weight_lbs).to eq(300)
    expect(prs.last.date).to eq(today)

  end
end
