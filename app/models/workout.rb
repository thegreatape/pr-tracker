class Workout < ApplicationRecord
  has_many :exercise_sets, dependent: :delete_all

  def self.create_from_parsed(parsed_workout, date, user_id)
    transaction do
      create!(
        date: date,
        raw_text: parsed_workout.raw_text,
        user_id: user_id,
        exercise_sets: parsed_workout.exercise_sets.map do |parsed_exercise_set|
          exercise = Exercise.find_or_create_by(name: parsed_exercise_set.exercise.name)
          ExerciseSet.new(
            bodyweight:       parsed_exercise_set.bodyweight,
            duration_seconds: parsed_exercise_set.duration_seconds,
            weight_lbs:       parsed_exercise_set.weight_lbs,
            reps:             parsed_exercise_set.reps,
            line_number:      parsed_exercise_set.line_number,
            user_id:          user_id,
            exercise:         exercise
          )
        end
      )
    end
  end
end
