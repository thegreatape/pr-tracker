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
        select max(weight_lbs) as weight_lbs, max(workouts.date) as date, reps, exercise_id, now(), now()
        from exercise_sets
        join workouts on exercise_sets.workout_id = workouts.id
        group by reps, exercise_id;
      SQL
    end
  end
end
