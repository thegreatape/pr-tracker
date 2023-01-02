class AddLineNumberToExerciseSets < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_sets, :line_number, :integer, null: false
  end
end
