class AddRawTextToWorkouts < ActiveRecord::Migration[7.0]
  def change
    add_column :workouts, :raw_text, :string
  end
end
