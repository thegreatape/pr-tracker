require 'rails_helper'

describe PrFinder do
  before(:each) do
    @user = FactoryBot.create(:user)
    @other_user = FactoryBot.create(:user)
  end

  it "reports rep PRs over time" do
    last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Deadlift
    270x5x3
    WORKOUT
    last_week_workout = Workout.create_from_parsed(Parser.new.parse(last_week_workout_text), last_week, @user.id)

    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    265x5x3
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday, @user.id)

    today = Date.today
    today_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    today_workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today, @user.id)

    expect(ExerciseSet.pr_sets.count).to eq(0)
    updated_workout_ids = PrFinder.update
    expect(updated_workout_ids).to match_array([last_week_workout.id, today_workout.id])
    expect(ExerciseSet.pr_sets.count).to eq(2)

    last_week_pr = last_week_workout.exercise_sets.pr_sets.first
    expect(last_week_pr.exercise.name).to eq("Deadlift")
    expect(last_week_pr.reps).to eq(5)
    expect(last_week_pr.weight_lbs).to eq(270)

    today_pr = today_workout.exercise_sets.pr_sets.first
    expect(today_pr.exercise.name).to eq("Deadlift")
    expect(today_pr.reps).to eq(3)
    expect(today_pr.weight_lbs).to eq(300)
  end

  it "marks PRs on synonyms as PRs for the main exercise" do
    # Create main exercise and synonym
    bench_press = Exercise.create!(name: "Bench Press")
    bench = Exercise.create!(name: "Bench", synonym_of: bench_press)

    # Create workouts with the synonym
    last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Bench
    185x5x3
    WORKOUT
    last_week_workout = Workout.create_from_parsed(Parser.new.parse(last_week_workout_text), last_week, @user.id)

    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Bench
    190x5x3
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday, @user.id)

    # Run PR finder
    expect(ExerciseSet.pr_sets.count).to eq(0)
    updated_workout_ids = PrFinder.update
    expect(updated_workout_ids).to match_array([last_week_workout.id, yesterday_workout.id])
    expect(ExerciseSet.pr_sets.count).to eq(2)

    # Verify both sets are marked as PRs
    last_week_pr = last_week_workout.exercise_sets.pr_sets.first
    expect(last_week_pr.exercise.name).to eq("Bench")
    expect(last_week_pr.reps).to eq(5)
    expect(last_week_pr.weight_lbs).to eq(185)
    expect(last_week_pr.latest_pr).to be false

    yesterday_pr = yesterday_workout.exercise_sets.pr_sets.first
    expect(yesterday_pr.exercise.name).to eq("Bench")
    expect(yesterday_pr.reps).to eq(5)
    expect(yesterday_pr.weight_lbs).to eq(190)
    expect(yesterday_pr.latest_pr).to be true

    # Create a workout with the main exercise name that beats the synonym's PR
    today = Date.today
    today_workout_text = <<~WORKOUT
    # Bench Press
    195x5x3
    WORKOUT
    today_workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today, @user.id)

    # Run PR finder again
    updated_workout_ids = PrFinder.update
    expect(updated_workout_ids).to match_array([yesterday_workout.id, today_workout.id])
    expect(ExerciseSet.pr_sets.count).to eq(3)

    # Verify all three sets are marked as PRs
    last_week_pr = last_week_workout.exercise_sets.pr_sets.first
    expect(last_week_pr.exercise.name).to eq("Bench")
    expect(last_week_pr.reps).to eq(5)
    expect(last_week_pr.weight_lbs).to eq(185)
    expect(last_week_pr.latest_pr).to be false

    yesterday_pr = yesterday_workout.exercise_sets.pr_sets.first
    expect(yesterday_pr.exercise.name).to eq("Bench")
    expect(yesterday_pr.reps).to eq(5)
    expect(yesterday_pr.weight_lbs).to eq(190)
    expect(yesterday_pr.latest_pr).to be false

    today_pr = today_workout.exercise_sets.pr_sets.first
    expect(today_pr.exercise.name).to eq("Bench Press")
    expect(today_pr.reps).to eq(5)
    expect(today_pr.weight_lbs).to eq(195)
    expect(today_pr.latest_pr).to be true
  end

  it "reports now-surpassed rep PRs and marks them not latest" do
    last_week = Date.today - 1.week
    last_week_workout_text = <<~WORKOUT
    # Deadlift
    290x3
    WORKOUT
    last_week_workout = Workout.create_from_parsed(Parser.new.parse(last_week_workout_text), last_week, @user.id)

    expect(ExerciseSet.pr_sets.count).to eq(0)
    PrFinder.update
    expect(ExerciseSet.pr_sets.count).to eq(1)

    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday, @user.id)

    today = Date.today
    today_workout_text = <<~WORKOUT

    # Deadlift
    300x3
    WORKOUT
    today_workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today, @user.id)

    expect(ExerciseSet.pr_sets.count).to eq(1)
    PrFinder.update
    expect(ExerciseSet.pr_sets.count).to eq(2)

    last_week_pr = last_week_workout.exercise_sets.pr_sets.first
    expect(last_week_pr.exercise.name).to eq("Deadlift")
    expect(last_week_pr.reps).to eq(3)
    expect(last_week_pr.weight_lbs).to eq(290)
    expect(last_week_pr.latest_pr).to be false

    yesterday_pr = yesterday_workout.exercise_sets.pr_sets.first
    expect(yesterday_pr.exercise.name).to eq("Deadlift")
    expect(yesterday_pr.reps).to eq(3)
    expect(yesterday_pr.weight_lbs).to eq(300)
    expect(yesterday_pr.latest_pr).to be true
  end

  it "picks the correct set to mark as a PR" do
    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    * Deadlift - 3x300
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday, @user.id)

    today = Date.today
    today_workout_text = <<~WORKOUT

    * Deadlift - 3x310, 3x3x270
    WORKOUT
    today_workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today, @user.id)

    PrFinder.update

    latest_prs = ExerciseSet.pr_sets.where(latest_pr: true)
    expect(latest_prs.count).to eq(1)

    pr_set = latest_prs.first
    expect(pr_set.workout.date).to eq(today)
    expect(pr_set.reps).to eq(3)
    expect(pr_set.weight_lbs).to eq(310)
  end

  it "updates prior prs if an edit renders them no longer valid" do
    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday, @user.id)

    today = Date.today
    today_workout_text = <<~WORKOUT

    # Deadlift
    310x3
    WORKOUT
    today_workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today, @user.id)

    expect(ExerciseSet.pr_sets.count).to eq(0)
    PrFinder.update
    yesterday_workout.reload
    today_workout.reload
    expect(ExerciseSet.pr_sets.count).to eq(2)

    yesterday_set = yesterday_workout.exercise_sets.first
    expect(yesterday_set).to be_pr
    expect(yesterday_set).to_not be_latest_pr

    today_set = today_workout.exercise_sets.first
    expect(today_set).to be_pr
    expect(today_set).to be_latest_pr

    today_workout.exercise_sets.first.update(weight_lbs: 270)

    updated_workouts = PrFinder.update
    expect(updated_workouts).to eq([yesterday_workout.id, today_workout.id])
    yesterday_workout.reload
    today_workout.reload
    expect(ExerciseSet.pr_sets.count).to eq(1)

    yesterday_set = yesterday_workout.exercise_sets.first
    expect(yesterday_set).to be_pr
    expect(yesterday_set).to be_latest_pr

    today_set = today_workout.exercise_sets.first
    expect(today_set).to_not be_pr
    expect(today_set).to_not be_latest_pr
  end

  it "updates prior prs if an edit renders them now the latest PR" do
    yesterday = Date.today - 1.day
    yesterday_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(yesterday_workout_text), yesterday, @user.id)
    yesterday_workout.exercise_sets.first.update!(latest_pr: false)

    expect(yesterday_workout.exercise_sets.first).to_not be_latest_pr
    PrFinder.update
    yesterday_workout.reload
    expect(yesterday_workout.exercise_sets.first).to be_latest_pr
  end

  it "separates rep PRs by user" do
    today = Date.today
    today_workout_text = <<~WORKOUT
    # Deadlift
    300x3
    WORKOUT
    today_workout = Workout.create_from_parsed(Parser.new.parse(today_workout_text), today, @user.id)

    yesterday = today - 1.day
    other_user_today_workout_text = <<~WORKOUT
    # Deadlift
    310x3
    WORKOUT
    yesterday_workout = Workout.create_from_parsed(Parser.new.parse(other_user_today_workout_text), yesterday, @other_user.id)

    expect(ExerciseSet.pr_sets.count).to eq(0)
    PrFinder.update
    expect(ExerciseSet.pr_sets.count).to eq(2)

    yesterday_pr = yesterday_workout.exercise_sets.pr_sets.first
    expect(yesterday_pr.exercise.name).to eq("Deadlift")
    expect(yesterday_pr.reps).to eq(3)
    expect(yesterday_pr.weight_lbs).to eq(310)
    expect(yesterday_pr.user).to eq(@other_user)

    today_pr = today_workout.exercise_sets.pr_sets.first
    expect(today_pr.exercise.name).to eq("Deadlift")
    expect(today_pr.reps).to eq(3)
    expect(today_pr.weight_lbs).to eq(300)
    expect(today_pr.user).to eq(@user)
  end
end
