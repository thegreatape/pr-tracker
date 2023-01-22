require 'rails_helper'

describe "workout display", js: true do
  it "shows PRs inline on workout list"
  describe "by workout" do
    # TODO make this not the default index action?
    it "allows listing workouts without empty days"
  end

  describe "by date" do
    before :each do
      @yesterday = Date.today - 1.day
      @yesterday_workout_text = <<~WORKOUT
      # Deadlift
      300x3
      WORKOUT
      @yesterday_workout = Workout.create_from_parsed(Parser.new.parse(@yesterday_workout_text), @yesterday)
    end

    def date_selector(date)
      "[id='#{date.strftime('%Y-%m-%d')}']"
    end

    it "allows adding a new workout to a date without an existing workout" do
      visit by_date_workouts_path

      expect(page).to have_content(Date.today.to_s)

      within date_selector(Date.today) do
        click_on 'Log Workout'

        today_workout_text = <<~WORKOUT
        # Squat
        250x5x5
        WORKOUT

        fill_in 'Workout', with: today_workout_text
        expect(page).to have_current_path(by_date_workouts_path)
        click_on 'Create Workout'

        expect(page).to have_content(today_workout_text)
      end

      expect(page).to have_current_path(by_date_workouts_path)
    end

    it "allows editing existing workouts"
    it "allows deleting existing workouts"
    it "allows cancelling adding a new workout"
    it "allows cancelling editing an existing workout"
  end
end
