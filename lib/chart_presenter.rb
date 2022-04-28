ChartPresenter = Struct.new(:prs) do
  def as_chart_data
    prs.group_by {|s| s.exercise.name}.map do |exercise_name, pr_sets|
      {
        label: exercise_name,
        data: pr_sets.map { |set|
          {
            x: set.date.to_time.to_i * 1000,
            y: set.weight_lbs,
            reps: set.reps
          }
        }
      }
    end
  end
end
