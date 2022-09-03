require 'parser'
require 'exercise'
require 'exercise_set'
require 'date'

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

    workout = Parser.new.parse(workout_text, Date.new)
    expect(workout.exercises.map(&:name)).to match_array [
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

    workout = Parser.new.parse(workout_text, Date.new)
    expect(workout.exercises.length).to eq(1)
    expect(workout.exercises.first.name).to eq("Deadlift")
    expect(workout.exercises.first.sets.length).to eq(4)
    expect(workout.exercises.first.sets.map(&:weight_lbs)).to eq([265, 265, 265, 265])
    expect(workout.exercises.first.sets.map(&:reps)).to eq([8, 5, 5, 5])
    expect(workout.exercises.first.sets.map(&:exercise).map(&:name)).to eq(['Deadlift', 'Deadlift','Deadlift','Deadlift'])
  end

  it "parses units" do
    workout_text = <<~WORKOUT
      #Deadlift
      265lbs x 8
      265lbs x 5 x 3

      #Kettlebell Swing
      24kg x 20 x 5
      WORKOUT

    workout = Parser.new.parse(workout_text, Date.new)
    expect(workout.exercises.length).to eq(2)
    expect(workout.exercises.first.name).to eq("Deadlift")
    expect(workout.exercises.first.sets.length).to eq(4)
    expect(workout.exercises.first.sets.map(&:weight_lbs)).to eq([265, 265, 265, 265])
    expect(workout.exercises.first.sets.map(&:reps)).to eq([8, 5, 5, 5])
    expect(workout.exercises.first.sets.map(&:exercise).map(&:name)).to eq(['Deadlift', 'Deadlift','Deadlift','Deadlift'])

    expect(workout.exercises.last.name).to eq("Kettlebell Swing")
    expect(workout.exercises.last.sets.length).to eq(5)
    expect(workout.exercises.last.sets.map(&:weight_lbs)).to all be_within(0.1).of(52.8)
    expect(workout.exercises.last.sets.map(&:reps)).to all eq(20)
    expect(workout.exercises.last.sets.map(&:exercise).map(&:name)).to all eq("Kettlebell Swing")
  end

  it "parses bodyweight exercises" do
    workout_text = <<~WORKOUT
    #Pull-up
    BW x 5 x 2
    WORKOUT

    workout = Parser.new.parse(workout_text, Date.new)
    expect(workout.exercises.length).to eq(1)
    expect(workout.exercises.first.name).to eq("Pull Up")
    expect(workout.exercises.first.sets.length).to eq(2)
    expect(workout.exercises.first.sets.map(&:weight_lbs)).to all be_nil
    expect(workout.exercises.first.sets.map(&:bodyweight)).to all be true
  end

  it "parses duration based exercises" do

    workout_text = <<~WORKOUT
    #Bike
    20 min
    WORKOUT

    workout = Parser.new.parse(workout_text, Date.new)
    expect(workout.exercises.length).to eq(1)
    expect(workout.exercises.first.name).to eq("Bike")
    expect(workout.exercises.first.sets.length).to eq(1)
    expect(workout.exercises.first.sets.map(&:weight_lbs)).to all be_nil
    expect(workout.exercises.first.sets.map(&:duration_seconds)).to all eq(1200)
  end

  it "parses fractional weights" do

    workout_text = <<~WORKOUT
    # H Curl
    27.5 x 10 x 4
    WORKOUT

    workout = Parser.new.parse(workout_text, Date.new)
    expect(workout.exercises.length).to eq(1)
    expect(workout.exercises.first.name).to eq("H Curl")
    expect(workout.exercises.first.sets.map(&:weight_lbs)).to all eq(27.5)
  end

  describe "reddit/markdown logs" do
    it "parses straight sets with non-specified accessory work" do
      workout_text = <<~WORKOUT
      **Bullmastiff W1D1**

      * Yukon Bar Squat - 6/6/6/13 x 225
      * RDL - 3 x 12 x 185
      * Belt squats, pulldowns, meadows rows, leg extensions
      WORKOUT

      workout = Parser.new.parse(workout_text, Date.new)

      expect(workout.exercises.length).to eq(2)
      expect(workout.exercises.first.name).to eq("Squat") # synonym
      expect(workout.exercises.first.sets.map(&:weight_lbs)).to all eq(225)
      expect(workout.exercises.first.sets.take(3).map(&:reps)).to all eq(6)
      expect(workout.exercises.first.sets.last.reps).to eq(13)

      expect(workout.exercises.last.name).to eq("Romanian Deadlift") # synonym
      expect(workout.exercises.last.sets.map(&:weight_lbs)).to all eq(185)
      expect(workout.exercises.last.sets.map(&:reps)).to all eq(12)
    end

    it "parses supersets" do

      workout_text = <<~WORKOUT
      **GGBB D1**

      * OHP - 6/3/3/3/3 x 135 - SS w/ rear delt flies 17/15/12/10 x 15
      * Inc BP - 12/8/8/8/8 x 115 - SS w/ lat raises 18/15/12/8 x 15
      * KB snatch 10x10 x 16kg EMOM
      WORKOUT

      workout = Parser.new.parse(workout_text, Date.new)

      expect(workout.exercises.length).to eq(5)

      expect(workout.exercises.first.name).to eq("Overhead Press")
      expect(workout.exercises.first.sets.map(&:weight_lbs)).to all eq(135)
      expect(workout.exercises.first.sets.first.reps).to eq(6)
      expect(workout.exercises.first.sets.drop(1).map(&:reps)).to eq([3,3,3,3])

      expect(workout.exercises[1].name).to eq("Rear Delt Fly")
      expect(workout.exercises[1].sets.map(&:weight_lbs)).to all eq(15)
      expect(workout.exercises[1].sets.map(&:reps)).to eq([17, 15, 12, 10])

      expect(workout.exercises[2].name).to eq("Incline Bench")
      expect(workout.exercises[2].sets.map(&:weight_lbs)).to all eq(115)
      expect(workout.exercises[2].sets.map(&:reps)).to eq([12, 8, 8, 8, 8])

      expect(workout.exercises[3].name).to eq("Lat Raises")
      expect(workout.exercises[3].sets.map(&:weight_lbs)).to all eq(15)
      expect(workout.exercises[3].sets.map(&:reps)).to eq([18, 15, 12, 8])

      expect(workout.exercises[4].name).to eq("Kettlebell Snatch")
      expect(workout.exercises[4].sets.map(&:weight_lbs)).to all eq(16 * 2.2)
      expect(workout.exercises[4].sets.count).to eq(10)
      expect(workout.exercises[4].sets.map(&:reps)).to all eq(10)
    end
  end
end
