class AddBenchmarkLiftToExercises < ActiveRecord::Migration[7.0]
  def change
    add_column :exercises, :benchmark_lift, :boolean, default: false, null: false
  end
end
