class PRFinder
  attr_reader :workouts

  def initialize(workouts)
    @workouts = workouts
  end

  def prs
    # exercise name =>
    #   { reps => exercise_set }
    best_sets = {}

    workouts.each do |workout|
      workout.exercises.flat_map(&:sets).each do |current_set|
        exercise_name = current_set.exercise.name
        best_sets[exercise_name] ||= {}
        existing_pr = best_sets[exercise_name].filter {|reps, pr_set| reps == current_set.reps}[1]
        if existing_pr.nil? || existing_pr.weight_lbs < current_set.weight_lbs
          best_sets[exercise_name][current_set.reps] = current_set
        end
      end
    end

    best_sets.values.flat_map(&:values)
  end
end
