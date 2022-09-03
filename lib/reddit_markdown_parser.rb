class RedditMarkdownParser
  SETS_RE = /
    (\s*[-\*]\s*)            # optional leading dash or star surrounded by optional whitespace
    (?<name>.*)              # name of exercise
    (\s*-\s*)                # optional dash surrounded by optional whitespace
    (                        # either:
      (                      #
      (?<sets>\d+)           #   sets
      \s*x\s*                #   x surrounded by optional whitespace
      (?<reps>\d+)           #   reps
      )                      #
      |                      # OR
      (?<rep_counts>[\d\/]+) #   any number of rep count slash rep count slash rep count
    )                        #
    \s*x\s*                  # x surrounded by optional whitespace
    (?<weight>[\d\.]+|BW)    # weight (or BW for bodyweight)
    (?<units>lbs|kg)?        # optional units
    /x

  def parse(contents, date)
    workout = Workout.new(date)

    contents.split("\n").each do |line|
      if match = SETS_RE.match(line)
        name = match[:name].squish.titleize
        name = Parser::SYNONYMS[name] || name
        exercise = Exercise.new(name)
        workout.exercises << exercise
        reps_by_set = if rep_counts = match[:rep_counts]
           rep_counts.split('/')
        else
          set_count = (match[:sets] || 1).to_i
          [match[:reps].to_i] * set_count
        end

        reps_by_set.each do |reps|
          weight = match[:weight] == "BW" ? nil : match[:weight].to_f
          if match[:units] == "kg"
            weight = weight * 2.2
          end
          exercise.sets << ExerciseSet.new(reps: reps.to_i, weight_lbs: weight, exercise: exercise, workout: workout, bodyweight: match[:weight] == "BW")
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
