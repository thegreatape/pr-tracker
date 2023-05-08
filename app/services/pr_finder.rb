class PrFinder
  attr_reader :workouts

  def initialize(workouts)
    @workouts = workouts
  end

  def self.update
    modified_rows = ActiveRecord::Base.connection.execute <<-SQL
      with rep_maxes_in_workout as (
        select
          max(weight_lbs) weight_lbs,
          max(id) as exercise_set_id,
          workout_id,
          reps,
          exercise_id,
          user_id
        from exercise_sets
        group by workout_id, reps, exercise_id, user_id
      ), maxes_by_date as (
        select
           weight_lbs,
           workouts.date as date,
           reps,
           exercise_id,
           exercise_set_id,
           rep_maxes_in_workout.user_id as user_id,
           max(weight_lbs) over (partition by rep_maxes_in_workout.user_id, exercise_id, reps order by date) max_to_date
        from rep_maxes_in_workout
          join workouts on workout_id = workouts.id
        where weight_lbs is not null
      ), maxes_with_previous_max as (
         select *,
         lag(max_to_date) over (partition by user_id, exercise_id, reps order by date) prev_max_weight
         from maxes_by_date
      ), ranked_maxes as (
         select *,
           row_number() over (partition by user_id, exercise_id, reps order by weight_lbs desc)
         from maxes_with_previous_max
         where (max_to_date > prev_max_weight or prev_max_weight is null)
      )
      update exercise_sets
      set pr = (ranked_maxes.exercise_set_id = exercise_sets.id and ranked_maxes.exercise_set_id is not null),
          latest_pr = (ranked_maxes.exercise_set_id = exercise_sets.id and row_number = 1 and ranked_maxes.exercise_set_id is not null),
          updated_at = now()
      from exercise_sets sets
        left join ranked_maxes on ranked_maxes.exercise_set_id = sets.id
      where
        (ranked_maxes.exercise_set_id = exercise_sets.id and sets.pr = false)
        or
        (ranked_maxes.exercise_set_id is null and sets.pr = true)
      returning exercise_sets.workout_id
    SQL

    return modified_rows.map{ |r| r["workout_id"]}.uniq
  end
end
