require 'rails_helper'

describe Parser do
  it "parses execise names" do
    workout_text = <<~WORKOUT
      #Deadlift
      265 x 8
      265 x 5 x 3

      #Safety bar squat
      160 x 8 x 3

      #Reverse ring fly
      BW x 8 x 3

      #Calf raise
      250 x 5 x 3

      #Ab roller
      BW x 3 x 3
      WORKOUT

    workout = Parser.new.parse(workout_text)
    expect(workout.exercise_sets.map(&:exercise).map(&:name).uniq).to match_array [
      "Deadlift",
      "Safety Bar Squat",
      "Reverse Ring Fly",
      "Calf Raise",
      "Ab Roller"
    ]
  end

  it "parses reps and sets" do
    workout_text = <<~WORKOUT
      #Deadlift
      265 x 8
      265 x 5 x 3
      WORKOUT

    workout = Parser.new.parse(workout_text)
    expect(workout.exercise_sets.length).to eq(4)
    expect(workout.exercise_sets.map(&:exercise).map(&:name)).to all eq("Deadlift")
    expect(workout.exercise_sets.map(&:weight_lbs)).to eq([265, 265, 265, 265])
    expect(workout.exercise_sets.map(&:reps)).to eq([8, 5, 5, 5])
  end

  it "parses units" do
    workout_text = <<~WORKOUT
      #Deadlift
      265lbs x 8
      265lbs x 5 x 3

      #Kettlebell Swing
      24kg x 20 x 5
      WORKOUT

    workout = Parser.new.parse(workout_text)
    expect(workout.exercise_sets.length).to eq(9)

    deadlift_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Deadlift"}
    expect(deadlift_sets.length).to eq(4)
    expect(deadlift_sets.map(&:weight_lbs)).to eq([265, 265, 265, 265])
    expect(deadlift_sets.map(&:reps)).to eq([8, 5, 5, 5])
    expect(deadlift_sets.map(&:exercise).map(&:name)).to eq(['Deadlift', 'Deadlift','Deadlift','Deadlift'])

    kb_swing_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Kettlebell Swing"}
    expect(kb_swing_sets.length).to eq(5)
    expect(kb_swing_sets.map(&:weight_lbs)).to all be_within(0.1).of(52.8)
    expect(kb_swing_sets.map(&:reps)).to all eq(20)
    expect(kb_swing_sets.map(&:exercise).map(&:name)).to all eq("Kettlebell Swing")
  end

  it "parses bodyweight exercises" do
    workout_text = <<~WORKOUT
    #Pull-up
    BW x 5 x 2
    WORKOUT

    workout = Parser.new.parse(workout_text)
    expect(workout.exercise_sets.length).to eq(2)
    expect(workout.exercise_sets.map(&:exercise).map(&:name)).to all eq("Pull Up")
    expect(workout.exercise_sets.map(&:weight_lbs)).to all be_nil
    expect(workout.exercise_sets.map(&:bodyweight)).to all be true
  end

  it "parses duration based exercises" do

    workout_text = <<~WORKOUT
    #Bike
    20 min
    WORKOUT

    workout = Parser.new.parse(workout_text)
    expect(workout.exercise_sets.length).to eq(1)
    expect(workout.exercise_sets.map(&:exercise).map(&:name)).to all eq("Bike")
    expect(workout.exercise_sets.map(&:weight_lbs)).to all be_nil
    expect(workout.exercise_sets.map(&:duration_seconds)).to all eq(1200)
  end

  it "parses fractional weights" do

    workout_text = <<~WORKOUT
    # H Curl
    27.5 x 10 x 4
    WORKOUT

    workout = Parser.new.parse(workout_text)
    expect(workout.exercise_sets.length).to eq(4)
    expect(workout.exercise_sets.map(&:exercise).map(&:name)).to all eq("H Curl")
    expect(workout.exercise_sets.map(&:weight_lbs)).to all eq(27.5)
  end

  describe "reddit/markdown logs" do
    it "parses straight sets with non-specified accessory work" do
      workout_text = <<~WORKOUT
      **Bullmastiff W1D1**

      * Yukon Bar Squat - 6/6/6/13 x 225
      * RDL - 3 x 12 x 185
      * Belt squats, pulldowns, meadows rows, leg extensions
      WORKOUT

      workout = Parser.new.parse(workout_text)

      squat_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Squat"} # synonym
      expect(squat_sets.map(&:weight_lbs)).to all eq(225)
      expect(squat_sets.take(3).map(&:reps)).to all eq(6)
      expect(squat_sets.last.reps).to eq(13)

      rdl_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Romanian Deadlift"} # synonym
      expect(rdl_sets.map(&:weight_lbs)).to all eq(185)
      expect(rdl_sets.map(&:reps)).to all eq(12)
    end

    it "parses supersets" do
      workout_text = <<~WORKOUT
      **GGBB D1**

      * OHP - 6/3/3/3/3 x 135 - SS w/ rear delt flies 17/15/12/10 x 15
      * Inc BP - 12/8/8/8/8 x 115 - SS w/ lat raises 18/15/12/8 x 15
      * KB snatch 10x10 x 16kg EMOM
      WORKOUT

      workout = Parser.new.parse(workout_text)

      ohp_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Overhead Press"} # synonym
      expect(ohp_sets.map(&:weight_lbs)).to all eq(135)
      expect(ohp_sets.first.reps).to eq(6)
      expect(ohp_sets.drop(1).map(&:reps)).to eq([3,3,3,3])

      rd_fly_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Rear Delt Fly"}
      expect(rd_fly_sets.map(&:weight_lbs)).to all eq(15)
      expect(rd_fly_sets.map(&:reps)).to eq([17, 15, 12, 10])

      incline_bench_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Incline Bench"}
      expect(incline_bench_sets.map(&:weight_lbs)).to all eq(115)
      expect(incline_bench_sets.map(&:reps)).to eq([12, 8, 8, 8, 8])

      lat_raise_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Lat Raises"}
      expect(lat_raise_sets.map(&:weight_lbs)).to all eq(15)
      expect(lat_raise_sets.map(&:reps)).to eq([18, 15, 12, 8])

      kb_snatch_sets = workout.exercise_sets.filter {|s| s.exercise.name == "Kettlebell Snatch"}
      expect(kb_snatch_sets.map(&:weight_lbs)).to all eq(16 * 2.2)
      expect(kb_snatch_sets.count).to eq(10)
      expect(kb_snatch_sets.map(&:reps)).to all eq(10)
    end

    it "parses backoff work" do
      workout_text = <<~WORKOUT
      * Bench - 10x165, 3x10x140
      WORKOUT

      workout = Parser.new.parse(workout_text)

      expect(workout.exercise_sets.first.exercise.name).to eq("Bench Press")
      expect(workout.exercise_sets.first.weight_lbs).to eq(165)
      expect(workout.exercise_sets.first.reps).to eq(10)

      expect(workout.exercise_sets.drop(1).map(&:exercise).map(&:name)).to all eq("Bench Press")
      expect(workout.exercise_sets.drop(1).map(&:weight_lbs)).to eq([140, 140, 140])
      expect(workout.exercise_sets.drop(1).map(&:reps)).to eq([10, 10, 10])
    end

    it "returns the raw text of the workout" do
      workout_text = <<~WORKOUT
      * Bench - 10x165, 3x10x140
      WORKOUT

      workout = Parser.new.parse(workout_text)
      expect(workout.raw_text).to eq(workout_text)
    end
  end
end
