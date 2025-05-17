require 'rails_helper'

describe "workout display", js: true do
  before :each do
    @user = FactoryBot.create(:user)
    sign_in @user

    @yesterday = Date.today - 1.day
    @yesterday_workout_text = <<~WORKOUT
      # Deadlift
      300x3

      # BSS
      100x10x5
    WORKOUT
    @yesterday_workout = Workout.create_from_parsed(Parser.new.parse(@yesterday_workout_text), @yesterday, @user.id)
  end

  def date_selector(date)
    "[id='workout-on-#{date.strftime('%Y-%m-%d')}']"
  end

  def workout_contents(date)
    within "#{date_selector(date)} table.workout tbody" do
      return page.all('tr').map(&:text)
    end
  end

  describe "PR display" do
    it "shows PRs inline on workout list" do
      first_bss_set = @yesterday_workout.exercise_sets.find do |exercise_set|
        exercise_set.exercise.name == "Bss"
      end
      first_bss_set.update!(pr: true, latest_pr: true)

      visit workouts_path
      expect(workout_contents(@yesterday)).to eq([
        "# Deadlift",
        "300x3",
        "",
        "# BSS",
        "⭐️\n100x10x5",
      ])
    end
  end

  describe "CRUD" do
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

      within date_selector(Date.today) do
        expect(page).to have_text("Edit")
      end
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
        accept_alert do
          click_on 'Delete'
        end
      end

      expect(page).to have_text('Workout deleted')
      expect(page).to have_current_path(workouts_path)
      expect(Workout.find_by(date: @yesterday)).to be_nil

      within date_selector(@yesterday) do
        expect(page).to have_text("Log Workout")
      end
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

  describe "live updates when PRs happen" do
    it "updates new and existing workouts" do
      # make sure initial PRs are calculated
      PrFinderWorker.new.perform

      today = Date.today
      visit workouts_path

      # expect yesterday's DL to be a PR
      within date_selector(@yesterday) do
        expect(page).to have_text("Deadlift\n⭐️\n300x3")
      end

      #
      # add a new PR today that beats yesterday
      #
      within date_selector(today) do
        click_on 'Log Workout'

        today_workout_text = <<~WORKOUT
        # Deadlift
        305x3
        WORKOUT
        fill_in 'Workout', with: today_workout_text
        click_on 'Create Workout'
      end

      expect(page).to have_text('Workout created')
      Sidekiq::Worker.drain_all

      # expect today's DL to be a PR
      within date_selector(today) do
        expect(page).to have_text("Deadlift\n⭐️\n305x3")
      end

      # expect yesterday's DL to still be a PR
      within date_selector(@yesterday) do
        expect(page).to have_text("Deadlift\n⭐️\n300x3")
      end


      #
      # edit yesterday's PR to beat today's
      #
      within date_selector(@yesterday) do
        click_on 'Edit'

        yesterday_workout_text = <<~WORKOUT
        # Deadlift
        310x3
        WORKOUT
        fill_in 'Workout', with: yesterday_workout_text
        click_on 'Update Workout'
      end

      expect(page).to have_text('Workout updated')
      Sidekiq::Worker.drain_all

      # expect yesterday's DL to be a PR
      within date_selector(@yesterday) do
        expect(page).to have_text("Deadlift\n⭐️\n310x3")
      end

      # expect today's DL to not longer be a PR
      within date_selector(today) do
        expect(page).to have_text("Deadlift\n305x3")
      end
    end
  end
end
