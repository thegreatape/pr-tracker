require 'rails_helper'

describe "workout display", js: true do
  describe "PR display" do
    it "shows PRs inline on workout list"
  end

  describe "CRUD" do
    before :each do
      @yesterday = Date.today - 1.day
      @yesterday_workout_text = <<~WORKOUT
      # Deadlift
      300x3
      WORKOUT
      @yesterday_workout = Workout.create_from_parsed(Parser.new.parse(@yesterday_workout_text), @yesterday)
    end

    def date_selector(date)
      "[id='workout-on-#{date.strftime('%Y-%m-%d')}']"
    end

    it "allows adding a new workout to a date without an existing workout" do
      visit workouts_path

      expect(page).to have_content(Date.today.to_s)
      expect(page).to have_content(@yesterday.to_s)

      today_workout_text = <<~WORKOUT
      # Squat
      250x5x5
      WORKOUT

      within date_selector(Date.today) do
        click_on 'Log Workout'

        fill_in 'Workout', with: today_workout_text
        expect(page).to have_current_path(workouts_path)
        click_on 'Create Workout'
      end

      expect(page).to have_text('Workout created')
      expect(page).to have_current_path(workouts_path)
      expect(Workout.find_by(date: Date.today).raw_text).to eq(today_workout_text)
    end

    it "allows editing existing workouts" do
      visit workouts_path

      updated_workout_text = <<~WORKOUT
      # Squat
      250x5x5
      WORKOUT

      within date_selector(@yesterday) do
        click_on 'Edit'

        fill_in 'Workout', with: updated_workout_text
        expect(page).to have_current_path(workouts_path)
        click_on 'Update Workout'
      end

      expect(page).to have_text('Workout updated')
      expect(page).to have_current_path(workouts_path)
      expect(Workout.find_by(date: @yesterday).raw_text).to eq(updated_workout_text)
    end

    it "allows deleting existing workouts" do
      visit workouts_path

      within date_selector(@yesterday) do
        click_on 'Delete'
      end

      expect(page).to have_text('Workout deleted')
      expect(page).to have_current_path(workouts_path)
      expect(Workout.find_by(date: @yesterday)).to be_nil
    end

    it "allows cancelling adding a new workout" do
      visit workouts_path

      within date_selector(Date.today) do
        click_on 'Log Workout'

        expect(page).to have_no_text('Log Workout')
        click_on 'Cancel'
        expect(page).to have_text('Log Workout')
        expect(page).to have_current_path(workouts_path)
      end
    end

    it "allows cancelling editing an existing workout" do
      visit workouts_path

      within date_selector(@yesterday) do
        click_on 'Edit'

        expect(page).to have_no_text('Edit')
        click_on 'Cancel'
        expect(page).to have_text('Edit')
        expect(page).to have_current_path(workouts_path)
      end
    end
  end
end
