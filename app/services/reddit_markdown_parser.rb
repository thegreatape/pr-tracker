class RedditMarkdownParser
  SETS_RE = /
    (\s*[-\*]\s*)?           # optional leading dash or star surrounded by optional whitespace
    (?<name>[\w\s]*?)        # name of exercise
    (\s*-\s*)?               # optional dash surrounded by optional whitespace
    (                        # either:
      (                      #
      (?<sets>\d+)           #   sets
      \s*x\s*                #   x surrounded by optional whitespace
      (?<reps>\d+)           #   reps
      )                      #
      |                      # OR
      (?<rep_counts>(        #
        [\d\/]               #   any number of rep count slash rep count slash rep count
        |                    #
        (\d+\([HMEhme]\)\s*),#   with an optional hardness rating: H or M or E
      )+)                    #
    )                        #
    \s*x\s*                  # x surrounded by optional whitespace
    (?<weight>[\d\.]+|BW|\w+\sband) # weight (or BW for bodyweight or band)
    (?<units>lbs|kg)?        # optional units
    /x

  TITLE_RE = /^\*\*/
  COMMENT_RE = /^\/\//
  LINE_OR_SUPERSET_RE = /\n|\s*- SS w\/\s*/
  TOP_SET_RE = /(?<name>[\w\s]*?)(\s*-\s*)\s*\d+\s*x\s*\d+,\s*\d+\s*x\s*\d+/

  def parse(contents)
    workout = Parser::Workout.new(exercise_sets: [])
    lines = contents.split(LINE_OR_SUPERSET_RE).flat_map do |line|
      if match = TOP_SET_RE.match(line)
        top_set, backoff_sets = line.split(/,\s*/)
        backoff_sets = "#{match[:name]} #{backoff_sets}"
        [top_set, backoff_sets]
      else
        line
      end
    end

    lines.each do |line|
      if match = SETS_RE.match(line)
        #puts line
        #puts "name: #{match[:name]}"
        #puts "reps: #{match[:reps]}"
        #puts "sets: #{match[:sets]}"
        #puts "rep_counts: #{match[:rep_counts]}"
        #puts "weight: #{match[:weight]}"

        name = match[:name].squish.titleize
        name = Parser::SYNONYMS[name] || name
        exercise = Parser::Exercise.new(name: name)

        reps_by_set = if rep_counts = match[:rep_counts]
           rep_counts.split('/')
        else
          set_count = (match[:sets] || 1).to_i
          [match[:reps].to_i] * set_count
        end

        reps_by_set.each do |reps|
          is_bodyweight = match[:weight] =~ /(BW|\w+ band)/
          weight = is_bodyweight ? nil : match[:weight].to_f
          if match[:units] == "kg"
            weight = weight * 2.2
          end
          workout.exercise_sets << Parser::ExerciseSet.new(reps: reps.to_i, weight_lbs: weight, exercise: exercise, bodyweight: is_bodyweight)
        end
      elsif line.match(COMMENT_RE)
        # ignore
      elsif !line.match(TITLE_RE)
        if !line.chomp.empty?
          $stderr.puts "didn't match line |#{line}|"
          #raise "didn't match line:\n#{line}"
        end
      end
    end
    workout
  end
end
