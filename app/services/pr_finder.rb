class PrFinder
  attr_reader :workouts

  def initialize(workouts)
    @workouts = workouts
  end

  def self.update
    modified_rows = ActiveRecord::Base.connection.execute <<-SQL
      with exercise_groups as (
        select 
          exercises.id as exercise_id,
          coalesce(exercises.synonym_of_id, exercises.id) as main_exercise_id
        from exercises
      ),
      max_weights_in_workout as (
        select max(weight_lbs) as weight_lbs,
            workout_id,
            reps,
            exercise_id,
            user_id
        from exercise_sets
        group by workout_id, reps, exercise_id, user_id
      ),
      rep_maxes_in_workout as (
        select
          exercise_sets.weight_lbs,
          max(id) as exercise_set_id,
          exercise_sets.workout_id,
          exercise_sets.reps,
          exercise_groups.main_exercise_id as exercise_id,
          exercise_sets.user_id
        from exercise_sets
          join max_weights_in_workout on
            exercise_sets.workout_id = max_weights_in_workout.workout_id AND
            exercise_sets.reps = max_weights_in_workout.reps AND
            exercise_sets.exercise_id = max_weights_in_workout.exercise_id AND
            exercise_sets.user_id = max_weights_in_workout.user_id AND
            exercise_sets.weight_lbs = max_weights_in_workout.weight_lbs
          join exercise_groups on exercise_groups.exercise_id = exercise_sets.exercise_id
        group by
            exercise_sets.weight_lbs,
            exercise_sets.workout_id,
            exercise_sets.reps,
            exercise_groups.main_exercise_id,
            exercise_sets.user_id
      ),
      maxes_by_date as (
        select
          weight_lbs,
          workouts.date as date,
          reps,
          rep_maxes_in_workout.exercise_id as exercise_id,
          rep_maxes_in_workout.exercise_set_id as exercise_set_id,
          rep_maxes_in_workout.user_id as user_id,
          max(weight_lbs) over (partition by rep_maxes_in_workout.user_id, exercise_id, reps order by date) max_to_date
        from rep_maxes_in_workout
          join workouts on workout_id = workouts.id
        where weight_lbs is not null
      ),
      maxes_with_previous_max as (
        select maxes_by_date.*,
        lag(max_to_date) over (partition by user_id, exercise_id, reps order by date) prev_max_weight
        from maxes_by_date
      ),
      ranked_maxes as (
        select *,
          row_number() over (partition by user_id, exercise_id, reps order by weight_lbs desc)
        from maxes_with_previous_max
        where (max_to_date > prev_max_weight or prev_max_weight is null)
      ),
      sets_for_update as (
        select
          exercise_sets.id as exercise_set_id,
          ranked_maxes.exercise_set_id is not null as pr,
          ranked_maxes.exercise_set_id is not null and row_number = 1 as latest_pr
        from exercise_sets
          left join ranked_maxes on ranked_maxes.exercise_set_id = exercise_sets.id
        where
          (ranked_maxes.exercise_set_id is not null and
            (exercise_sets.pr = false
              or (exercise_sets.latest_pr = true and row_number > 1))
              or (exercise_sets.latest_pr = false and row_number = 1))
          or
          (ranked_maxes.exercise_set_id is null and exercise_sets.pr = true)
      )
      update exercise_sets
      set pr = sets_for_update.pr,
          latest_pr = sets_for_update.latest_pr,
          updated_at = now()
      from sets_for_update
      where exercise_sets.id = sets_for_update.exercise_set_id
      returning exercise_sets.workout_id
    SQL

    return modified_rows.map{ |r| r["workout_id"]}.uniq
  end
end
