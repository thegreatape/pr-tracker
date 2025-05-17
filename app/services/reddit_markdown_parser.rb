class RedditMarkdownParser
  SETS_RE = /
    (\s*[-\*]\s*)?                  # optional leading dash or star surrounded by optional whitespace
    (?<name>[\w\s]*?)               # name of exercise
    (\s*-\s*)?                      # optional dash surrounded by optional whitespace
    (                               # either:
      (                             #
      (?<sets>\d+)                  #   sets
      \s*x\s*                       #   x surrounded by optional whitespace
      (?<reps>\d+)                  #   reps
      )                             #
      |                             # OR
      (?<rep_counts>(               #
        [\d\/]                      #   any number of rep count slash rep count slash rep count
        |                           #   OR
        (\d+\([HMEhme]\)\s*),?      #   rep count with an optional hardness rating: H or M or E
      )+)                           #
    )                               #
    \s*x\s*                         # x surrounded by optional whitespace
    (?<weight>[\d\.]+|BW|\w+\sband) # weight (or BW for bodyweight or band)
    (?<units>lbs|kg)?               # optional units
    /x

  TITLE_RE = /^\*\*/
  COMMENT_RE = /^\/\//
  LINE_OR_SUPERSET_RE = /\n|\s*- SS w\/\s*/
  TOP_SET_RE = /(?<name>[\w\s]*?)(\s*-\s*)\s*\d+\s*x\s*\d+,\s*\d+\s*x\s*\d+/
  GG_SET_RE = /
  (?<name>[\w\s]*?)                      # exercise name
  (\s*-\s*)\s*                           # dash
  (?<rep_max_set>\d+\([HMEhme]\)\s*),\s* # rep count with hardness rating: H or M or E
  (?<backoff_sets>[\d\/]+)               # any number of rep count slash rep count slash rep count
  \s*x\s*                                # x surrounded by optional whitespace
  (?<weight>[\d\.]+|BW|\w+\sband)        # weight (or BW for bodyweight or band)
  (?<units>lbs|kg)?                      # optional units
  /x

  SplitLine = Struct.new(:line, :original_text_index)

  def parse(contents)
    workout = Parser::Workout.new(exercise_sets: [])
    lines = contents.split(LINE_OR_SUPERSET_RE).each_with_index.flat_map do |line, index|
      if match = TOP_SET_RE.match(line)
        top_set, backoff_sets = line.split(/,\s*/)
        backoff_sets = "#{match[:name]} #{backoff_sets}"
        [SplitLine.new(top_set, index), SplitLine.new(backoff_sets, index)]
      elsif match = GG_SET_RE.match(line)
        top_set, backoff_sets = line.split(/,\s*/)
        top_set = "#{top_set}x#{match[:weight]}"
        backoff_sets = "#{match[:name]} #{backoff_sets}"
        [SplitLine.new(top_set, index), SplitLine.new(backoff_sets, index)]
      else
        SplitLine.new(line, index)
      end
    end

    lines.each do |split_line|
      line = split_line.line
      index = split_line.original_text_index

      if match = SETS_RE.match(line)
        # puts line
        # puts "name: #{match[:name]}"
        # puts "reps: #{match[:reps]}"
        # puts "sets: #{match[:sets]}"
        # puts "rep_counts: #{match[:rep_counts]}"
        # puts "weight: #{match[:weight]}"

        name = match[:name].squish.titleize
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
          workout.exercise_sets << Parser::ExerciseSet.new(reps: reps.to_i, weight_lbs: weight, exercise: exercise, bodyweight: is_bodyweight, line_number: index+1)
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
