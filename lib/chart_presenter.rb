ChartPresenter = Struct.new(:prs) do
  SYNONYMS = {
    "Bench" => "Bench Press",
    "Bss" => "Bulgarian Split Squat",
    "Cable Upright Rows" => "Cable Upright Row",
    "Chin" => "Chin Up",
    "Dips" => "Dip",
    "Front Squats" => "Front Squat",
    "Hammer Curls" => "Hammer Curl",
    "Inc Bp" => "Incline Bench",
    "Incline Db Press" => "Incline Dumbbell Press",
    "Kb Press" => "Kettlebell Press",
    "Kb Row" => "Kettlebell Row",
    "Kb Snatch" => "Kettlebell Snatch",
    "Kb Swing" => "Kettlebell Swing",
    "Lat Pd" => "Lat Pulldown",
    "Oh Tri Ex" => "Oh Tri Ext",
    "Ohp" => "Overhead Press",
    "Pendlay Row" => "Barbell Row",
    "Rdl" => "Romanian Deadlift",
    "Rear Delt Flies 4x12x25," => "",
    "Rear Delt Flies" => "Rear Delt Fly",
    "Seal Rows" => "Seal Row",
    "Ssb" => "Safety Bar Squat",
    "Tbdl" => "Trap Bar Deadlift",
    "Trap Bar Deads" => "Trap Bar Deadlift",
    "Trap Bar Dl" => "Trap Bar Deadlift",
    "Tri Pushdowns" => "Tri Pushdown",
    "Yukon Bar Squat" => "Squat"
  }

  def normalize(name)
    SYNONYMS[name] || name
  end

  def as_chart_data
    prs.group_by {|s| s.exercise.name}.map do |exercise_name, pr_sets|
      {
        label: exercise_name,
        data: pr_sets.map { |set|
          {
            date: set.date.to_time.to_i * 1000,
            weight_lbs: set.weight_lbs,
            reps: set.reps
          }
        }
      }
    end
  end
end
