class WeightroomDotUkParser
  # looks likes:
  # #Reverse ring fly
  EXERCISE_NAME_RE = /
      \s*               # optional whitespace
      \#\s*(?<name>.*)  # pound sign followed by optional whitespace and name of exercise
      \s*               # optional whitespace
    /x

  SETS_RE = /
    (?<weight>[\d\.]+|BW) # weight (or BW for bodyweight)
    (?<units>lbs|kg)?     # optional units
    \s*x\s*               # x surrounded by optional whitespace
    (?<reps>\d+)          # reps
    (?:                   # optionally followed by
      \s*x\s*               # x surrounded by optional whitespace
      (?<sets>\d+)          # sets
    )?
    /x

  DURATION_RE = /
    ^\s*              # optional leading whitespace
    (?<duration>\d+)  # duration
    \s*               # optional space
    (?<units>sec|mins?) # units
    (?:               # optionally followed by
      \s*x\s*           # x surrounded by optional whitespace
      (?<sets>\d+)      # sets
    )?
    \s*$              # optional trailing whitespace
    /x

  def parse(contents, date)
    workout = Workout.new(date)
    current_exercise = nil

    contents.split("\n").each do |line|
      if match = EXERCISE_NAME_RE.match(line)
        name = match[:name].squish.titleize
        name = Parser::SYNONYMS[name] || name
        current_exercise = Exercise.new(name)
        workout.exercises << current_exercise
      elsif match = SETS_RE.match(line)
        set_count = (match[:sets] || 1).to_i
        set_count.times do
          weight = match[:weight] == "BW" ? nil : match[:weight].to_f
          if match[:units] == "kg"
            weight = weight * 2.2
          end
          current_exercise.sets << ExerciseSet.new(reps: match[:reps].to_i, weight_lbs: weight, exercise: current_exercise, workout: workout, bodyweight: match[:weight] == "BW")
        end
      elsif match = DURATION_RE.match(line)
        set_count = (match[:sets] || 1).to_i
        set_count.times do
          duration = match[:duration].to_i
          if match[:units].starts_with?("min")
            duration *= 60
          end
          current_exercise.sets << ExerciseSet.new(exercise: current_exercise, workout: workout, duration_seconds: duration)
        end
      else
        if !line.chomp.empty?
          $stderr.puts "didn't match line for #{date}: |#{line}|"
          #raise "didn't match line:\n#{line}"
        end
      end
    end
    workout
  end
end
