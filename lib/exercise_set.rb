class ExerciseSet
  attr_reader :reps
  attr_reader :weight_lbs
  attr_reader :exercise
  attr_reader :workout

  def initialize(reps:, weight_lbs:, exercise:, workout:)
    @reps = reps
    @weight_lbs = weight_lbs
    @exercise = exercise
    @workout = workout
  end

  def date
    workout.date
  end
end
