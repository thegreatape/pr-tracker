class AddUserToDateConstraintIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :workouts, :date, unique: true
    add_index :workouts, [:date, :user_id], unique: true
  end
end
