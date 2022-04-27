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
      "Safety bar squat",
      "Reverse ring fly",
      "Calf raise",
      "Ab roller"
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
end
