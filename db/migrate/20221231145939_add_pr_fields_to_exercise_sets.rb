class AddPrFieldsToExerciseSets < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_sets, :pr, :boolean, default: false, null: false
    add_column :exercise_sets, :latest_pr, :boolean, default: false, null: false
  end
end
