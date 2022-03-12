require 'workout'
require 'exercise_set'

class Parser
  # looks likes:
  # #Reverse ring fly
  EXERCISE_NAME_RE = /
      \s*            # optional whitespace
      \#(?<name>.*)  # pound sign followed by name of exercise
      \s*            # optional whitespace
    /x

  SETS_RE = /
    (?<weight>\d+) # weight
    \s*x\s*        # x surrounded by optional whitespace
    (?<reps>\d+)   # reps
    (?:            # optionally followed by
      \s*x\s*         # x surrounded by optional whitespace
      (?<sets>\d+)    # sets
    )?
    /x

  def parse(contents)
    workout = Workout.new
    current_exercise = nil

    contents.split("\n").each do |line|
      if match = EXERCISE_NAME_RE.match(line)
        current_exercise = Exercise.new(match[:name])
        workout.exercises << current_exercise
      elsif match = SETS_RE.match(line)
        set_count = (match[:sets] || 1).to_i
        set_count.times do
          current_exercise.sets << ExerciseSet.new(reps: match[:reps].to_i, weight_lbs: match[:weight].to_i)
        end
      else
        if !line.chomp.empty?
          puts "didn't match line:\n#{line}"
        end
      end
    end
    workout
  end
end
