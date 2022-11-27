class InitialModelImport < ActiveRecord::Migration[7.0]
  def change
    create_table :exercises do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :workouts do |t|
      t.date :date, null: false
    end

    create_table :exercise_sets do |t|
      t.references :exercise, foreign_key: true, null: false
      t.references :workout, foreign_key: true, null: false
      t.boolean :bodyweight, default: false
      t.integer :duration_seconds
      t.decimal :weight_lbs, precision: 8, scale: 2
      t.integer :reps

      t.timestamps
    end
  end
end
