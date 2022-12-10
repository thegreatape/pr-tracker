class AddPrSets < ActiveRecord::Migration[7.0]
  def change
    create_table :pr_sets do |t|
      t.decimal :weight_lbs, precision: 8, scale: 2
      t.integer :reps, null: false
      t.date :date, null: false

      t.references :exercise, foreign_key: true, null: false

      t.timestamps
    end
  end
end
