class AddExerciseSetToPrSets < ActiveRecord::Migration[7.0]
  def change
    add_reference :pr_sets, :exercise_set, null: false, foreign_key: true
  end
end
