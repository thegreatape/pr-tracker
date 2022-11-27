class PrFinder
  attr_reader :workouts

  def initialize(workouts)
    @workouts = workouts
  end

  def prs
    # exercise name =>
    #   { reps => exercise_set }
    best_to_date = {}
    pr_sets = []

    workouts.each do |workout|
      workout.exercise_sets
        .filter {|e| !e.bodyweight && !e.duration_seconds }
        .each do |current_set|
          exercise_name = current_set.exercise.name
          best_to_date[exercise_name] ||= {}
          existing_pr = best_to_date[exercise_name][current_set.reps]
          if existing_pr.nil? || existing_pr.weight_lbs < current_set.weight_lbs
            best_to_date[exercise_name][current_set.reps] = current_set
            pr_sets << current_set
          end
        end
    end

    pr_sets.sort_by(&:date)
  end
end
