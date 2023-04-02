class AddUniqueConstraintToWorkoutDate < ActiveRecord::Migration[7.0]
  def change
    add_index :workouts, :date, unique: true
  end
end
