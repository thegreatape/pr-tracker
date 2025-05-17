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

ActiveRecord::Schema[7.0].define(version: 2025_05_17_125731) do
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
    t.bigint "user_id", null: false
    t.index ["exercise_id"], name: "index_exercise_sets_on_exercise_id"
    t.index ["workout_id"], name: "index_exercise_sets_on_workout_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "synonym_of_id"
    t.boolean "benchmark_lift", default: false, null: false
    t.index ["synonym_of_id"], name: "index_exercises_on_synonym_of_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "raw_text"
    t.bigint "user_id", null: false
    t.index ["date", "user_id"], name: "index_workouts_on_date_and_user_id", unique: true
  end

  add_foreign_key "exercise_sets", "exercises"
  add_foreign_key "exercise_sets", "users"
  add_foreign_key "exercise_sets", "workouts"
  add_foreign_key "exercises", "exercises", column: "synonym_of_id"
  add_foreign_key "workouts", "users"
end
