# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_02_134121) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exercise_sets", force: :cascade do |t|
    t.bigint "exercise_id", null: false
    t.bigint "workout_id", null: false
    t.boolean "bodyweight", default: false
    t.integer "duration_seconds"
    t.decimal "weight_lbs", precision: 8, scale: 2
    t.integer "reps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pr", default: false, null: false
    t.boolean "latest_pr", default: false, null: false
    t.integer "line_number", null: false
    t.index ["exercise_id"], name: "index_exercise_sets_on_exercise_id"
    t.index ["workout_id"], name: "index_exercise_sets_on_workout_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workouts", force: :cascade do |t|
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "raw_text"
    t.index ["date"], name: "index_workouts_on_date", unique: true
  end

  add_foreign_key "exercise_sets", "exercises"
  add_foreign_key "exercise_sets", "workouts"
end
