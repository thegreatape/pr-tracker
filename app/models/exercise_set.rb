class ExerciseSet < ApplicationRecord
  belongs_to :exercise
  belongs_to :workout

  def date
    workout.date
  end

  def to_s
    "#{date} - #{exercise.name} - #{reps} x #{weight_lbs}lbs"
  end
end
