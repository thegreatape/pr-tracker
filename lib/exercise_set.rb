class ExerciseSet
  attr_reader :reps
  attr_reader :weight_lbs
  attr_reader :exercise
  attr_reader :workout
  attr_reader :bodyweight
  attr_reader :duration_seconds

  def initialize(exercise:, workout:, reps: nil, weight_lbs: nil, bodyweight: false, duration_seconds: nil)
    @reps = reps
    @weight_lbs = weight_lbs
    @exercise = exercise
    @workout = workout
    @bodyweight = bodyweight
    @duration_seconds = duration_seconds
  end

  def date
    workout.date
  end

  def to_s
    "#{date} - #{exercise.name} - #{reps} x #{weight_lbs}lbs"
  end
end
