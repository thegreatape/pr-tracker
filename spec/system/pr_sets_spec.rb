require 'rails_helper'

describe "PR display" do
  before :each do
    @last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Deadlift
    270x5x3

    # Squat
    225x3
    WORKOUT
    @last_week_workout = Workout.create_from_parsed(Parser.new.parse(last_week_workout_text), @last_week)

    @yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    265x5x3

    # Bench
    180x3
    WORKOUT
    @yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), @yesterday)

    PrFinder.update

    @bench_press = Exercise.find_by(name: "Bench Press")
    @deadlift = Exercise.find_by(name: "Deadlift")
    @squat = Exercise.find_by(name: "Squat")
  end

  it "shows the latest PRs by date"

  it "shows the latest PRs by exercise" do
    visit pr_sets_path

    bench_table = page.find("table#exercise-#{@bench_press.id}")
    expect(bench_table).to be_present

    rows = table_contents(bench_table)
    expect(rows.count).to eq(20)

    pr_row = rows.find {|r| r["Reps"] == "3"}
    expect(pr_row).to eq({
      "Date" => @yesterday.strftime("%Y-%m-%d"),
      "Reps" => "3",
      "Weight (lbs)" => "180",
      "e1RM" => "197",
    })
  end
end
