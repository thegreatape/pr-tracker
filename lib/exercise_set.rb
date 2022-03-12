class ExerciseSet
  attr_reader :reps
  attr_reader :weight_lbs

  def initialize(reps:, weight_lbs:)
    @reps = reps
    @weight_lbs = weight_lbs
  end
end
