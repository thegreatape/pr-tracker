require 'rails_helper'

describe PrFinder do
  it "reports rep PRs over time" do
    last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Deadlift
    270x5x3
    WORKOUT
    Workout.create_from_parsed(Parser.new.parse(last_week_workout_text), last_week)

    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    265x5x3
    WORKOUT
    Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday)

    today = Date.today
    today_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    Workout.create_from_parsed(Parser.new.parse(today_workout_text), today)

    expect(PrSet.count).to eq(0)
    PrFinder.update
    expect(PrSet.count).to eq(2)

    last_week_pr = PrSet.where(date: last_week).first
    expect(last_week_pr.exercise.name).to eq("Deadlift")
    expect(last_week_pr.reps).to eq(5)
    expect(last_week_pr.weight_lbs).to eq(270)

    today_pr = PrSet.where(date: today).first
    expect(today_pr.exercise.name).to eq("Deadlift")
    expect(today_pr.reps).to eq(3)
    expect(today_pr.weight_lbs).to eq(300)
  end

  it "reports now-surpassed rep PRs and marks them not latest" do
    last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Deadlift
    290x3
    WORKOUT
    Workout.create_from_parsed(Parser.new.parse(last_week_workout_text), last_week)

    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday)

    today = Date.today
    today_workout_text = <<~WORKOUT

    # Deadlift
    300x3
    WORKOUT
    Workout.create_from_parsed(Parser.new.parse(today_workout_text), today)

    expect(PrSet.count).to eq(0)
    PrFinder.update
    expect(PrSet.count).to eq(2)

    last_week_pr = PrSet.where(date: last_week).first
    expect(last_week_pr.exercise.name).to eq("Deadlift")
    expect(last_week_pr.reps).to eq(3)
    expect(last_week_pr.weight_lbs).to eq(290)
    expect(last_week_pr.latest).to be false

    yesterday_pr = PrSet.where(date: yesterday).first
    expect(yesterday_pr.exercise.name).to eq("Deadlift")
    expect(yesterday_pr.reps).to eq(3)
    expect(yesterday_pr.weight_lbs).to eq(300)
    expect(yesterday_pr.latest).to be true
  end

  it "stores the exercise set id of the pr" do
    today = Date.today
    today_workout_text = <<~WORKOUT

    # Deadlift
    300x3
    WORKOUT
    workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today)

    PrFinder.update

    expect(PrSet.count).to eq(1)
    expect(workout.exercise_sets.count).to eq(1)

    expect(PrSet.first.exercise_set_id).to eq(workout.exercise_sets.first.id)
  end

end
