class AddUserIdToWorkoutsAndSets < ActiveRecord::Migration[7.0]
  def change
    add_column :exercise_sets, :user_id, :bigint, index: true, null: false
    add_foreign_key :exercise_sets, :users

    add_column :workouts, :user_id, :bigint, index: true, null: false
    add_foreign_key :workouts, :users
  end
end
