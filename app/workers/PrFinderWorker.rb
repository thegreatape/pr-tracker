class PrFinderWorker
  include Sidekiq::Job

  def perform
    updated_workout_ids = PrFinder.update
    Workout.where(id: updated_workout_ids).find_each do |workout|
      workout.broadcast_replace
    end
  end
end
