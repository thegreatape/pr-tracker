class ExerciseSet < ApplicationRecord
  belongs_to :exercise
  belongs_to :workout
  belongs_to :user

  scope :pr_sets, -> { where(pr: true) }

  def date
    workout.date
  end

  def to_s
    "#{date} - #{exercise.name} - #{reps} x #{weight_lbs}lbs"
  end

  def e1rm
    return weight_lbs.to_i if reps == 1

    if reps <= 10
      ((weight_lbs * 0.033 * reps) + weight_lbs).to_i
    end
  end
end
