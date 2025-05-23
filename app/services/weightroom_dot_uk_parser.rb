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

  def parse(contents)
    workout = Parser::Workout.new(exercise_sets: [])
    current_exercise = nil

    contents.split("\n").each_with_index do |line, index|
      if match = EXERCISE_NAME_RE.match(line)
        name = match[:name].squish.titleize
        current_exercise = Parser::Exercise.new(name: name)
      elsif match = SETS_RE.match(line)
        set_count = (match[:sets] || 1).to_i
        set_count.times do
          weight = match[:weight] == "BW" ? nil : match[:weight].to_f
          if match[:units] == "kg"
            weight = weight * 2.2
          end
          workout.exercise_sets << Parser::ExerciseSet.new(reps: match[:reps].to_i, weight_lbs: weight, exercise: current_exercise, bodyweight: match[:weight] == "BW", line_number: index + 1)
        end
      elsif match = DURATION_RE.match(line)
        set_count = (match[:sets] || 1).to_i
        set_count.times do
          duration = match[:duration].to_i
          if match[:units].starts_with?("min")
            duration *= 60
          end
          workout.exercise_sets << Parser::ExerciseSet.new(exercise: current_exercise, duration_seconds: duration, line_number: index + 1)
        end
      else
        if !line.chomp.empty?
          $stderr.puts "didn't match line |#{line}|"
          #raise "didn't match line:\n#{line}"
        end
      end
    end
    workout
  end
end
