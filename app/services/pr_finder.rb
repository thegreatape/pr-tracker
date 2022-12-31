class PrFinder
  attr_reader :workouts

  def initialize(workouts)
    @workouts = workouts
  end

  def self.update
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        with rep_maxes_in_workout as (
          select
            max(weight_lbs) weight_lbs,
            max(id) as exercise_set_id,
            workout_id,
            reps,
            exercise_id
          from exercise_sets
          group by workout_id, reps, exercise_id
        ), maxes_by_date as (
          select
             weight_lbs,
             workouts.date as date,
             reps,
             exercise_id,
             exercise_set_id,
             max(weight_lbs) over (partition by exercise_id, reps order by date) max_to_date
          from rep_maxes_in_workout
            join workouts on workout_id = workouts.id
          where weight_lbs is not null
        ), maxes_with_previous_max as (
           select *,
             lag(max_to_date) over (partition by exercise_id, reps order by date) prev_max_weight
           from maxes_by_date
        ), ranked_maxes as (
           select *,
             row_number() over (partition by exercise_id, reps order by weight_lbs desc)
           from maxes_with_previous_max
           where (max_to_date > prev_max_weight or prev_max_weight is null)
        )
        update exercise_sets
        set pr = true,
            latest_pr = (row_number = 1),
            updated_at = now()
        from ranked_maxes
        where ranked_maxes.exercise_set_id = exercise_sets.id
      SQL
    end
  end
end
