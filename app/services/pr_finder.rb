class PrFinder
  attr_reader :workouts

  def initialize(workouts)
    @workouts = workouts
  end

  def self.update
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        delete from pr_sets;
      SQL

      ActiveRecord::Base.connection.execute <<-SQL
        insert into pr_sets (weight_lbs, date, reps, exercise_id, created_at, updated_at)
        select weight_lbs, date, reps, exercise_id, now(), now()
        from (
          select
             weight_lbs as weight_lbs,
             workouts.date as date,
             reps,
             exercise_id,
             row_number() over (partition by exercise_id, reps order by weight_lbs desc)
          from exercise_sets
            join workouts on exercise_sets.workout_id = workouts.id
          where weight_lbs is not null
        ) t
        where row_number = 1
      SQL
    end
  end
end
